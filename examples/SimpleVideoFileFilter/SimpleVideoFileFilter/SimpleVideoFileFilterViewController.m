#import "SimpleVideoFileFilterViewController.h"

@implementation SimpleVideoFileFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"sample_iPod" withExtension:@"m4v"];
    
    movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
//    filter = [[GPUImagePixellateFilter alloc] init];
    filter = [[GPUImageUnsharpMaskFilter alloc] init];
    GPUImageRotationFilter *rotationFilter = [[GPUImageRotationFilter alloc] initWithRotation:kGPUImageRotateRight];
    
    [movieFile addTarget:filter];

    // Only rotate the video for display, leave orientation the same for recording
    GPUImageView *filterView = (GPUImageView *)self.view;
    [filter addTarget:rotationFilter];
    [rotationFilter addTarget:filterView];

    // In addition to displaying to the screen, write out a processed version of the movie to disk
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];

    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    movieWriter.shouldPassthroughAudio = YES;
    [filter addTarget:movieWriter];
    movieFile.audioEncodingTarget = movieWriter;
    movieWriter.shouldDropFramesIfOverloaded = NO;
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    [movieWriter setCompletionBlock:^{
        [filter removeTarget:movieWriter];
        [movieWriter finishRecording];
    }];

    /*
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [filter removeTarget:movieWriter];
        [movieWriter finishRecording];
        NSLog(@"Done recording");
    });
     */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)updatePixelWidth:(id)sender
{
    [(GPUImageUnsharpMaskFilter *)filter setIntensity:[(UISlider *)sender value]];
//    pixellateFilter.fractionalWidthOfAPixel = [(UISlider *)sender value];
}

@end
