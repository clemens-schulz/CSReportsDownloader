//  ReportDownloader.h
//
//  Copyright (c) 2015 Clemens Schulz
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <Foundation/Foundation.h>

/// Report type
typedef NS_ENUM(NSInteger, CSReportType) {
    CSReportTypeSales,
    CSReportTypeNewsstand
};

/// Report subtype
typedef NS_ENUM(NSInteger, CSReportSubtype) {
    CSReportSubtypeSummary,
    CSReportSubtypeDetailed,
    CSReportSubtypeOptIn
};

/// Date type for reports
typedef NS_ENUM(NSInteger, CSDateType) {
    CSDateTypeDaily,
    CSDateTypeWeekly,
    CSDateTypeMonthly,
    CSDateTypeYearly
};

/**
 Class used for downloading reports from iTunes Connect
 */
@interface CSReportsDownloader : NSObject

@property (nonatomic, strong) NSString *userID; /// iTunes Connect Apple ID
@property (nonatomic, strong) NSString *password; /// Password for iTunes Connect
@property (nonatomic, strong) NSString *vendorID; /// An unique vendor number
@property (nonatomic, assign) CSReportType reportType; /// Report type
@property (nonatomic, assign) CSReportSubtype reportSubtype; /// Report subtype
@property (nonatomic, assign) CSDateType dateType; /// Report date type

/**
 Downloads reports from iTunes Connect.
 @param date The date of the report you are requesting. If nil, yesterday will be used.
 @param completionHandler Called when download is complete. location is the url to the downloaded file. suggestedFilename is the suggested filename. error is nil, if no error occured.
 @return NSURLSessionDownloadTask object used to download the file. You do not need to call resume.
 */
- (NSURLSessionDownloadTask *)downloadReportForDate:(NSDate *)date completionHandler:(void (^)(NSURL *location, NSString *suggestedFilename, NSError *error))completionHandler;

@end

/// Error domain name for errors returned by iTunes Connect.
extern NSString * const CSReportsDownloaderErrorDomain;