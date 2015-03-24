CSReportsDownloader is a simple class to download reports from iTunes Connect. It does the same as Apples Autoingestion-Tool, but does not use Java.

## How To Use

	CSReportsDownloader *downloader = [[CSReportsDownloader alloc] init];
	downloader.userID = @"<AppleID>";
	downloader.password = @"<Password>";
	downloader.vendorID = @"<VendorID>";
	downloader.reportType = CSReportTypeSales;
	downloader.reportSubtype = CSReportSubtypeSummary;
	downloader.dateType = CSDateTypeDaily;
	
	[downloader downloadReportForDate:nil completionHandler:^(NSURL *location, NSString *suggestedFilename, NSError *error) {
	    if (error != nil) {
			NSLog(@"Error: %@", error);
	    } else {
	        // Success. Downloaded report is at 'location'.
	    }
	}];

## License

CSReportsDownloader is available under the MIT license. See the LICENSE file for more info.