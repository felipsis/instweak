#import <Foundation/Foundation.h>

// Tell the compiler these properties exist so it doesn't throw compilation errors
@interface IGStoryTrayViewModel : NSObject
@property (nonatomic, assign) BOOL isUnseenNux;
@property (nonatomic, copy) NSString *pk;
@end

// Hook the exact data source class from the original code
%hook IGMainStoryTrayDataSource

- (id)allItemsForTrayUsingCachedValue:(BOOL)cached {
    // 1. Get the original array of stories from Instagram
    NSArray *originalObjs = %orig(cached);
    
    // 2. Create a mutable array to hold the stories we actually want to keep
    NSMutableArray *filteredObjs = [NSMutableArray arrayWithCapacity:[originalObjs count]];

    // 3. Loop through every story in the tray
    for (IGStoryTrayViewModel *obj in originalObjs) {
        BOOL shouldHide = NO;

        // No preference check here—this logic runs automatically every session
        if ([obj isKindOfClass:%c(IGStoryTrayViewModel)] && (obj.isUnseenNux == YES || [obj.pk isEqualToString:@"3538572169"])) {
            NSLog(@"[SCInsta] Removing ads: story tray");
            shouldHide = YES;
        }

        // 4. Only add the story to our new list if it's NOT supposed to be hidden
        if (!shouldHide) {
            [filteredObjs addObject:obj];
        }
    }

    // 5. Return the cleaned list back to Instagram
    return filteredObjs;
}

%end
