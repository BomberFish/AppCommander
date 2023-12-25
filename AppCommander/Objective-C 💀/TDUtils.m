#import "TDUtils.h"
#import "TDDumpDecrypted.h"
#import "LSApplicationProxy+AltList.h"

@implementation TDUtils: NSObject
UIWindow *alertWindow = NULL;
UIWindow *kw = NULL;
UIViewController *root = NULL;
UIAlertController *alertController = NULL;
UIAlertController *doneController = NULL;
UIAlertController *errorController = NULL;

- (NSArray *) appList; {
    NSMutableArray *apps = [NSMutableArray array];

    NSArray <LSApplicationProxy *> *installedApplications = [[LSApplicationWorkspace defaultWorkspace] atl_allInstalledApplications];
    [installedApplications enumerateObjectsUsingBlock:^(LSApplicationProxy *proxy, NSUInteger idx, BOOL *stop) {
        if (![proxy atl_isUserApplication]) return;

        NSString *bundleID = [proxy atl_bundleIdentifier];
        NSString *name = [proxy atl_nameToDisplay];
        NSString *version = [proxy atl_shortVersionString];
        NSString *executable = proxy.canonicalExecutablePath;

        if (!bundleID || !name || !version || !executable) return;

        NSDictionary *item = @{
            @"bundleID":bundleID,
            @"name":name,
            @"version":version,
            @"executable":executable
        };

        [apps addObject:item];
    }];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [apps sortUsingDescriptors:@[descriptor]];

    [apps addObject:@{@"bundleID":@"", @"name":@"", @"version":@"", @"executable":@""}];

    return [apps copy];
}

- (NSUInteger) iconFormat; {
    return (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 8 : 10;
}

- (NSArray *) sysctl_ps; {
    NSMutableArray *array = [[NSMutableArray alloc] init];

    int numberOfProcesses = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    pid_t pids[numberOfProcesses];
    bzero(pids, sizeof(pids));
    proc_listpids(PROC_ALL_PIDS, 0, pids, sizeof(pids));
    for (int i = 0; i < numberOfProcesses; ++i) {
        if (pids[i] == 0) { continue; }
        char pathBuffer[PROC_PIDPATHINFO_MAXSIZE];
        bzero(pathBuffer, PROC_PIDPATHINFO_MAXSIZE);
        proc_pidpath(pids[i], pathBuffer, sizeof(pathBuffer));

        if (strlen(pathBuffer) > 0) {
            NSString *processID = [[NSString alloc] initWithFormat:@"%d", pids[i]];
            NSString *processName = [[NSString stringWithUTF8String:pathBuffer] lastPathComponent];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil] forKeys:[NSArray arrayWithObjects:@"pid", @"proc_name", nil]];
            
            [array addObject:dict];
        }
    }

    return [array copy];
}

- (NSString *) decryptApp : (NSDictionary *) app error: (NSError **)error __attribute__((swift_error(nonnull_error))); {
    *error = nil;
    NSLog(@"[trolldecrypt] spawning thread to do decryption in background...");

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"[trolldecrypt] inside decryption thread.");

        NSString *bundleID = app[@"bundleID"];
        NSString *name = app[@"name"];
        NSString *version = app[@"version"];
        NSString *executable = app[@"executable"];
        NSString *binaryName = [executable lastPathComponent];

        NSLog(@"[trolldecrypt] bundleID: %@", bundleID);
        NSLog(@"[trolldecrypt] name: %@", name);
        NSLog(@"[trolldecrypt] version: %@", version);
        NSLog(@"[trolldecrypt] executable: %@", executable);
        NSLog(@"[trolldecrypt] binaryName: %@", binaryName);

        [[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:YES];
        sleep(1);

        pid_t pid = -1;
        NSArray *processes = [self sysctl_ps];
        for (NSDictionary *process in processes) {
            NSString *proc_name = process[@"proc_name"];
            if ([proc_name isEqualToString:binaryName]) {
                pid = [process[@"pid"] intValue];
                break;
            }
        }

        if (pid == -1) {
            *error = [NSError errorWithDomain:@"com.trolldecrypt" code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to get PID for binary name: %@", binaryName]}];
        }

        NSLog(@"[trolldecrypt] pid: %d", pid);
        @try {
            [self bfinject_rocknroll:pid appName:name version:version];
        } @catch(NSException *e) {
            *error = [NSError errorWithDomain:@"com.trolldecrypt" code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to decrypt %@. %@", name, e]}];
        }
    });
    
    if (*error != nil) {
        NSLog(@"[trolldecrypt] error: %@", *error);
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@_%@_decrypted.ipa", [self docPath], app[@"name"], app[@"version"]];
}

- (void) bfinject_rocknroll : (pid_t) pid appName: (NSString *) appName version: (NSString *) version; {
    NSLog(@"[trolldecrypt] Spawning thread to do decryption in the background...");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"[trolldecrypt] Inside decryption thread");

		char pathbuf[PROC_PIDPATHINFO_MAXSIZE];
    	// int proc_pidpath(pid, pathbuf, sizeof(pathbuf));
        proc_pidpath(pid, pathbuf, sizeof(pathbuf));
		const char *fullPathStr = pathbuf;


        NSLog(@"[trolldecrypt] fullPathStr: %s", fullPathStr);
        DumpDecrypted *dd = [[DumpDecrypted alloc] initWithPathToBinary:[NSString stringWithUTF8String:fullPathStr] appName:appName appVersion:version];
        if(!dd) {
            NSLog(@"[trolldecrypt] ERROR: failed to get DumpDecrypted instance");
            @throw [NSException exceptionWithName:@"DumpDecrypted" reason:@"Failed to get DumpDecrypted instance" userInfo:nil];
            return;
        }

        NSLog(@"[trolldecrypt] Full path to app: %s   ///   IPA File: %@", fullPathStr, [dd IPAPath]);
        // Do the decryption
        @try {
            [dd createIPAFile:pid];
        } @catch (NSException* err) {
            @throw err;
        }
        NSLog(@"[trolldecrypt] Over and out.");
        while(1)
            sleep(9999999);
    }); // dispatch in background
    
    NSLog(@"[trolldecrypt] All done, exiting constructor.");
}

- (NSArray *) decryptedFileList; {
    NSMutableArray *files = [NSMutableArray array];
    NSMutableArray *fileNames = [NSMutableArray array];

    // iterate through all files in the Documents directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtPath:[self docPath]];

    NSString *file;
    while (file = [directoryEnumerator nextObject]) {
        if ([[file pathExtension] isEqualToString:@"ipa"]) {
            NSString *filePath = [[[self docPath] stringByAppendingPathComponent:file] stringByStandardizingPath];

            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
            NSDate *modificationDate = fileAttributes[NSFileModificationDate];

            NSDictionary *fileInfo = @{@"fileName": file, @"modificationDate": modificationDate};
            [files addObject:fileInfo];
        }
    }

    // Sort the array based on modification date
    NSArray *sortedFiles = [files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [obj1 objectForKey:@"modificationDate"];
        NSDate *date2 = [obj2 objectForKey:@"modificationDate"];
        return [date2 compare:date1];
    }];

    // Get the file names from the sorted array
    for (NSDictionary *fileInfo in sortedFiles) {
        [fileNames addObject:[fileInfo objectForKey:@"fileName"]];
    }

    return [fileNames copy];
}

- (NSString *) docPath; {
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Library/AppCommander/DecryptedIPAs" withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"[trolldecrypt] error creating directory: %@", error);
    }

    return @"/var/mobile/Library/AppCommander/DecryptedIPAs";
}
//
//- (void) decryptAppWithPID : (pid_t) pid; {
//    // generate App NSDictionary object to pass into decryptApp()
//    // proc_pidpath(self.pid, buffer, sizeof(buffer));
//    NSString *message = nil;
//    NSString *error = nil;
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        alertWindow = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
//        alertWindow.rootViewController = [UIViewController new];
//        alertWindow.windowLevel = UIWindowLevelAlert + 1;
//        [alertWindow makeKeyAndVisible];
//        
//        // Show a "Decrypting!" alert on the device and block the UI
//            
//        kw = alertWindow;
//        if([kw respondsToSelector:@selector(topmostPresentedViewController)])
//            root = [kw performSelector:@selector(topmostPresentedViewController)];
//        else
//            root = [kw rootViewController];
//        root.modalPresentationStyle = UIModalPresentationFullScreen;
//    });
//
//    NSLog(@"[trolldecrypt] pid: %d", pid);
//
//    char pathbuf[PROC_PIDPATHINFO_MAXSIZE];
//    proc_pidpath(pid, pathbuf, sizeof(pathbuf));
//
//    NSString *executable = [NSString stringWithUTF8String:pathbuf];
//    NSString *path = [executable stringByDeletingLastPathComponent];
//    NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"Info.plist"]];
//    NSString *bundleID = infoPlist[@"CFBundleIdentifier"];
//
//    if (!bundleID) {
//        error = @"Error: -2";
//        message = [NSString stringWithFormat:@"Failed to get bundle id for pid: %d", pid];
//    }
//
//    LSApplicationProxy *app = [LSApplicationProxy applicationProxyForIdentifier:bundleID];
//    if (!app) {
//        error = @"Error: -3";
//        message = [NSString stringWithFormat:@"Failed to get LSApplicationProxy for bundle id: %@", bundleID];
//    }
//
//    if (message) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [alertController dismissViewControllerAnimated:NO completion:nil];
//            NSLog(@"[trolldecrypt] failed to get bundleid for pid: %d", pid);
//
//            errorController = [UIAlertController alertControllerWithTitle:error message:message preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                NSLog(@"[trolldecrypt] Ok action");
//                [errorController dismissViewControllerAnimated:NO completion:nil];
//                [kw removeFromSuperview];
//                kw.hidden = YES;
//            }];
//
//            [errorController addAction:okAction];
//            [root presentViewController:errorController animated:YES completion:nil];
//        });
//    }
//
//    NSLog(@"[trolldecrypt] app: %@", app);
//
//    NSDictionary *appInfo = @{
//        @"bundleID":bundleID,
//        @"name":[app atl_nameToDisplay],
//        @"version":[app atl_shortVersionString],
//        @"executable":executable
//    };
//
//    NSLog(@"[trolldecrypt] appInfo: %@", appInfo);
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [alertController dismissViewControllerAnimated:NO completion:nil];
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Decrypt" message:[NSString stringWithFormat:@"Decrypt %@?", appInfo[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//        UIAlertAction *decrypt = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            decryptApp(appInfo);
//        }];
//
//        [alert addAction:decrypt];
//        [alert addAction:cancel];
//        
//        [root presentViewController:alert animated:YES completion:nil];
//    });
//}
//
//- (void) github_fetchLatedVersion : (NSString *) repo completionHandler: (void (^)(NSString *latestVersion)) completionHandler; {
//    NSString *urlString = [NSString stringWithFormat:@"https://api.github.com/repos/%@/releases/latest", repo];
//    NSURL *url = [NSURL URLWithString:urlString];
//
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (!error) {
//            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//                NSError *jsonError;
//                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
//
//                if (!jsonError) {
//                    NSString *version = [json[@"tag_name"] stringByReplacingOccurrencesOfString:@"v" withString:@""];
//                    completionHandler(version);
//                }
//            }
//        }
//    }];
//
//    [task resume];
//}
//
//- (void) fetchLatestTrollDecryptVersion : (void (^)(NSString *version)) completionHandler; {
//    github_fetchLatedVersion(@"donato-fiore/TrollDecrypt", completionHandler);
//}
//
//- (NSString *) trollDecryptVersion; {
//    return [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
//}

@end
