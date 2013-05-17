//
//  MapViewController.m
//  FieldNotebook
//
//  Created by Ryan Worl on 3/19/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "MapViewController.h"
#import "FNCaseFileTableViewController.h"
#import "FNPoint.h"
#import "FNLine.h"
#import "FNShape.h"
#import "FNPointAnnotationView.h"
#import "FNEntityInspectorViewController.h"
#import "FNDataManager.h"

#define UNSELECTED_FILL [UIColor colorWithRed:0.9176 green:0.9098 blue:0.8117 alpha:0.8]

@interface MapViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet MKMapView* mapView;

@property (nonatomic, strong) NSMutableArray* currentAnnotations;
@property (nonatomic, strong) NSMutableArray* currentOverlays;

@property (nonatomic, strong) NSMutableArray* activePointAnns;
@property (nonatomic, strong) NSMutableArray* activePoints;

@property (nonatomic, strong) FNShape* activePolygon;
@property (nonatomic, strong) MKPolygonView* activePolygonView;
@property (nonatomic, strong) FNLine* activePolyline;
@property (nonatomic, strong) MKPolylineView* activePolylineView;

@property (nonatomic, assign) BOOL polygonModeSelected;
@property (nonatomic, assign) BOOL polylineModeSelected;
@property (nonatomic, assign) BOOL pointModeSelected;
@property (nonatomic, assign) BOOL photoModeSelected;

@property (nonatomic, strong) UIBarButtonItem* polygonModeButton;
@property (nonatomic, strong) UIBarButtonItem* polylineModeButton;
@property (nonatomic, strong) UIBarButtonItem* pointModeButton;
@property (nonatomic, strong) UIBarButtonItem* photoModeButton;

@property (nonatomic, strong) FNCaseFile* currentCaseFile;

@property (nonatomic, strong) UIPopoverController* popover;

@property (nonatomic, strong) UIImage* chosenImage;

@end

@implementation MapViewController 

- (id)init
{
    self = [super initWithNibName:@"MapViewController" bundle:nil];
    if (self) {
        self.activePoints = @[].mutableCopy;
        self.activePointAnns = @[].mutableCopy;
        self.currentAnnotations = @[].mutableCopy;
        self.currentOverlays = @[].mutableCopy;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.polygonModeButton = [[UIBarButtonItem alloc] initWithTitle:@"Polygon" style:UIBarButtonItemStylePlain target:self action:@selector(didTapPolygonMode:)];
    
    self.polylineModeButton = [[UIBarButtonItem alloc] initWithTitle:@"Line" style:UIBarButtonItemStylePlain target:self action:@selector(didTapPolylineMode:)];

    self.pointModeButton = [[UIBarButtonItem alloc] initWithTitle:@"Point" style:UIBarButtonItemStylePlain target:self action:@selector(didTapPointMode:)];
    
    self.photoModeButton = [[UIBarButtonItem alloc] initWithTitle:@"Photo" style:UIBarButtonItemStyleBordered target:self action:@selector(didTapPhotoMode:)];
    
    self.pointModeButton.enabled = NO;
    self.polylineModeButton.enabled = NO;
    self.polygonModeButton.enabled = NO;
    self.photoModeButton.enabled = NO;

    self.navigationItem.rightBarButtonItems = (@[
                                               self.polygonModeButton,
                                               self.polylineModeButton,
                                               self.pointModeButton,
                                               self.photoModeButton
                                               ]);
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(didTapMapView:)];
    [self.mapView addGestureRecognizer:tap];
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

#pragma mark - FNCaseFileSelectionDelegate

- (void)addCaseFileToMap:(FNCaseFile *)caseFile
{
    self.currentCaseFile = caseFile;
    
    [self.mapView removeAnnotations:self.currentAnnotations];
    [self.mapView removeOverlays:self.currentOverlays];
    [self.currentAnnotations removeAllObjects];
    [self.currentOverlays removeAllObjects];
    
    for (FNCard* c in caseFile.cards) {
        if (!c.isVisible) {
            continue;
        }
        
        for (id<FNEntity> e in c.entities) {
            if ([e conformsToProtocol:@protocol(MKAnnotation)]) {
                [self.currentAnnotations addObject:e];
                [self.mapView addAnnotation:((id<MKAnnotation>)e)];
            }
            if ([e isKindOfClass:[FNLine class]] || [e isKindOfClass:[FNShape class]]) {
                FNLine* line = (FNLine *)e;
                
                for (FNPoint* p in line.points) {
                    [self.currentAnnotations addObject:p];
                    [self.mapView addAnnotation:p];
                }
                
                [self.currentOverlays addObject:line.overlay];
                [self.mapView addOverlay:line.overlay];
            }
        }
    }
}

- (void)removeCaseFileFromMap:(FNCaseFile *)caseFile
{
    [self addCaseFileToMap:nil];
}

- (void)didSelectEntity:(id<FNEntity>)entity
{    
    if ([entity respondsToSelector:@selector(coordinate)]) {
        FNPoint* point = (FNPoint *)entity;
        MKMapRect r = [self.mapView visibleMapRect];
        MKMapPoint pt = MKMapPointForCoordinate(point.coordinate);
        r.origin.x = pt.x - r.size.width * 0.5;
        r.origin.y = pt.y - r.size.height * 0.5;
        [self.mapView setVisibleMapRect:r animated:YES];
    }
    if ([entity respondsToSelector:@selector(points)]) {
        FNLine* line = (FNLine *)entity;
        CLLocationCoordinate2D loc =  CLLocationCoordinate2DMake(0.0f, 0.0f);
                
        /*
         Take the average of the coordinates of this entity
         in order to find the geographic center
         */
        
        for (FNPoint* p in line.points) {
            loc.latitude  += p.coordinate.latitude;
            loc.longitude += p.coordinate.longitude;
        }
        
        loc.latitude  /= line.points.count;
        loc.longitude /= line.points.count;
        
        MKMapPoint pt = MKMapPointForCoordinate(loc);
        MKMapRect r = [self.mapView visibleMapRect];
        r.origin.x = pt.x - r.size.width * 0.5;
        r.origin.y = pt.y - r.size.height * 0.5;
        //[self.mapView setVisibleMapRect:r animated:YES];
        [self.mapView setVisibleMapRect:line.overlay.boundingMapRect animated:YES];
        
        if (line.points.count > 0) {
            FNPoint* firstPoint = line.points[0];
            [self.mapView selectAnnotation:firstPoint animated:YES];
        }
        
    }
    
}

- (void)enableCreationButtons
{
    self.pointModeButton.enabled = YES;
    self.polylineModeButton.enabled = YES;
    self.polygonModeButton.enabled = YES;
    self.photoModeButton.enabled = YES;
}

- (void)disableCreationButtons
{
    self.pointModeButton.enabled = NO;
    self.polylineModeButton.enabled = NO;
    self.polygonModeButton.enabled = NO;
    self.photoModeButton.enabled = NO;
}

- (void)reloadCurrentCaseFile
{
    [self addCaseFileToMap:self.currentCaseFile];
}

#pragma mark - Callbacks


- (void)didTapPointMode:(UIBarButtonItem *)sender
{    
    if (self.pointModeSelected) {
        self.pointModeButton.style = UIBarButtonItemStylePlain;
        self.polylineModeButton.style = UIBarButtonItemStylePlain;
        self.polygonModeButton.style = UIBarButtonItemStylePlain;
        self.photoModeButton.style = UIBarButtonItemStylePlain;
    } else {
        self.pointModeButton.style = UIBarButtonItemStyleDone;
        self.polylineModeButton.style = UIBarButtonItemStylePlain;
        self.polygonModeButton.style = UIBarButtonItemStylePlain;
        self.photoModeButton.style = UIBarButtonItemStylePlain;
    }
    
    self.pointModeSelected = !self.pointModeSelected;
    self.polygonModeSelected = NO;
    self.polylineModeSelected = NO;
    self.photoModeSelected = NO;
}

- (void)didTapPolygonMode:(UIBarButtonItem *)sender
{
    if (self.polygonModeSelected) {
        self.pointModeButton.style = UIBarButtonItemStylePlain;
        self.polylineModeButton.style = UIBarButtonItemStylePlain;
        self.polygonModeButton.style = UIBarButtonItemStylePlain;
        self.photoModeButton.style = UIBarButtonItemStylePlain;
        
        if (self.activePolygon) {
            NSLog(@"active polygon non-null");
            [self.currentOverlays addObject:self.activePolygon.overlay];
            [[NSNotificationCenter defaultCenter] postNotificationName:FNMapViewControllerDidCreateNewEntity object:self.activePolygon];
            [self reloadCurrentCaseFile];
            self.activePolygon = nil;
            self.activePoints = @[].mutableCopy;
            self.activePointAnns = @[].mutableCopy;
        }
        
    } else {
        self.pointModeButton.style = UIBarButtonItemStylePlain;
        self.polylineModeButton.style = UIBarButtonItemStylePlain;
        self.polygonModeButton.style = UIBarButtonItemStyleDone;
        self.photoModeButton.style = UIBarButtonItemStylePlain;
    }
    
    self.pointModeSelected = NO;
    self.polygonModeSelected = !self.polygonModeSelected;
    self.polylineModeSelected = NO;
    self.photoModeSelected = NO;
}

- (void)didTapPhotoMode:(UIBarButtonItem *)sender
{
    if (self.photoModeSelected) {
        self.photoModeButton.style = UIBarButtonItemStylePlain;
        self.pointModeButton.style = UIBarButtonItemStylePlain;
        self.polylineModeButton.style = UIBarButtonItemStylePlain;
        self.polygonModeButton.style = UIBarButtonItemStylePlain;
    } else {
        [self choosePhoto];

        self.photoModeButton.style = UIBarButtonItemStyleDone;
        self.pointModeButton.style = UIBarButtonItemStylePlain;
        self.polylineModeButton.style = UIBarButtonItemStylePlain;
        self.polygonModeButton.style = UIBarButtonItemStylePlain;
    }
    
    self.photoModeSelected = !self.photoModeSelected;
    self.pointModeSelected = NO;
    self.polygonModeButton = NO;
    self.polylineModeButton = NO;
}

- (void)didTapPolylineMode:(UIBarButtonItem *)sender
{
    if (self.polylineModeSelected) {
        self.pointModeButton.style = UIBarButtonItemStylePlain;
        self.polylineModeButton.style = UIBarButtonItemStylePlain;
        self.polygonModeButton.style = UIBarButtonItemStylePlain;
        self.photoModeButton.style = UIBarButtonItemStylePlain;
        
        if (self.activePolyline) {
            [self.currentOverlays addObject:self.activePolyline.overlay];
            [[NSNotificationCenter defaultCenter] postNotificationName:FNMapViewControllerDidCreateNewEntity object:self.activePolyline];
            [self reloadCurrentCaseFile];
            self.activePolyline = nil;
            self.activePoints = @[].mutableCopy;
            self.activePointAnns = @[].mutableCopy;
        }
        
    } else {
        self.pointModeButton.style = UIBarButtonItemStylePlain;
        self.polylineModeButton.style = UIBarButtonItemStyleDone;
        self.polygonModeButton.style = UIBarButtonItemStylePlain;
        self.photoModeButton.style = UIBarButtonItemStylePlain;
    }
    
    self.pointModeSelected = NO;
    self.polygonModeSelected = NO;
    self.photoModeSelected = NO;
    self.polylineModeSelected = !self.polylineModeSelected;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.chosenImage = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[FNPoint class]]) {
        FNPoint* point = (FNPoint *)view.annotation;
        if ([point.parent isKindOfClass:[FNShape class]]) {
            FNShape* parent = (FNShape *)point.parent;
            MKPolygonView* polygonView = (MKPolygonView *)[self.mapView viewForOverlay:parent.overlay];
            polygonView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        }
    }

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    FNPoint* point = (FNPoint *)view.annotation;
    id<FNEntity> entity = nil;
    
    if (point.parent) {
        entity = point.parent;
    } else {
        entity = point;
    }
    
    [self.mapView deselectAnnotation:point animated:YES];
    
    FNEntityInspectorViewController* vc = [[FNEntityInspectorViewController alloc] initWithEntity:entity];
    self.popover = [[UIPopoverController alloc] initWithContentViewController:vc];
    self.popover.popoverContentSize = CGSizeMake(320, 260);
    [self.popover presentPopoverFromRect:view.bounds inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

-       (void)mapView:(MKMapView *)mapView
       annotationView:(MKAnnotationView *)annotationView
   didChangeDragState:(MKAnnotationViewDragState)newState
         fromOldState:(MKAnnotationViewDragState)oldState
{

    if ([annotationView.annotation isKindOfClass:[FNPoint class]]) {
        NSLog(@"annotation:%@", annotationView.annotation);
        
        FNPoint* point = (FNPoint *)annotationView.annotation;
        
        id lineOrShape = point.parent;
        if ([lineOrShape isKindOfClass:[FNShape class]]) {
            FNShape* shape = (FNShape *)lineOrShape;
                        
            [self.currentOverlays removeObject:shape];
            [self.mapView removeOverlay:shape.overlay];
                        
            [shape makeOverlay];
            
            [self.mapView addOverlay:shape.overlay];
            [self.currentOverlays addObject:shape.overlay];
        }
        if ([lineOrShape isKindOfClass:[FNLine class]]) {
            FNLine* line = (FNLine *)lineOrShape;
            
            [self.currentOverlays removeObject:line];
            [self.mapView removeOverlay:line.overlay];
            
            [line makeOverlay];
            
            [self.mapView addOverlay:line.overlay];
            [self.currentOverlays addObject:line.overlay];
        }
        
    }
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[FNPoint class]]) {
        FNPoint* p = (FNPoint *)annotation;
        
        MKAnnotationView* view = nil;
        
        if (p.parent) {
            static NSString* identifier = @"Point";
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (!view) {
                view = [[FNPointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
                view.canShowCallout = YES;
            }
        } else {
            static NSString* identifier = @"Pin";
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (!view) {
                MKPinAnnotationView* pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
                pin.animatesDrop = YES;
                pin.canShowCallout = YES;
                [pin setDraggable:YES];
                pin.pinColor = MKPinAnnotationColorGreen;
                
                view = pin;
            }
           
        }

        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        button.frame = CGRectMake(0, 0, 30, 30);
        button.tag = [self.currentAnnotations indexOfObject:annotation];
        view.rightCalloutAccessoryView = button;
        
        return view;
    }

    //NSLog(@"ann: %@", annotation);
    
    static NSString* identifier = @"Pin";
    MKPinAnnotationView* pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    pin.animatesDrop = YES;
    pin.canShowCallout = YES;
    [pin setDraggable:YES];
    pin.pinColor = MKPinAnnotationColorGreen;
    
    return pin;
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKOverlayView* view = nil;
    
	if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonView* polygonView = [[MKPolygonView alloc] initWithPolygon:overlay];
        polygonView.lineWidth = 0.5;
        polygonView.strokeColor = [UIColor whiteColor];
        polygonView.fillColor = UNSELECTED_FILL;
    
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPolygon:)];
        [polygonView addGestureRecognizer:tap];
        
        view = polygonView;
    }
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView* polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        polylineView.lineWidth = 10.0f;
        polylineView.lineJoin = kCGLineCapRound;
        polylineView.strokeColor = [UIColor blueColor];
        polylineView.fillColor = [UIColor whiteColor];
        polylineView.userInteractionEnabled = YES;
        

        
        view = polylineView;
    }
    
    return view;
}

- (void)didTapPolygon:(id)sender
{
    NSLog(@"%@", sender);
}

#pragma mark -

- (void)choosePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.allowsEditing = NO;
        cameraUI.delegate = self;
        
        [self.navigationController presentViewController:cameraUI animated:YES completion:nil];
    }
}

- (void)updatePolygon
{
    if (self.activePoints.count == 0) {
        return;
    }
    
    FNPoint* p = [[FNPoint alloc] init];
    p.coordinate = [[self.activePoints lastObject] MKCoordinateValue];
    [self.mapView addAnnotation:p];
    [self.currentAnnotations addObject:p];
    [self.activePointAnns addObject:p];
    
    [self.mapView removeOverlay:self.activePolygon.overlay];
    self.activePolygon = [[FNShape alloc] initWithPoints:self.activePointAnns];
    [self.mapView addOverlay:self.activePolygon.overlay];
}

- (void)updatePolyline
{
    if (self.activePoints.count == 0) {
        return;
    }
    
    FNPoint* p = [[FNPoint alloc] init];
    p.coordinate = [[self.activePoints lastObject] MKCoordinateValue];
    [self.mapView addAnnotation:p];
    [self.currentAnnotations addObject:p];
    [self.activePointAnns addObject:p];
    
    [self.mapView removeOverlay:self.activePolyline.overlay];
    self.activePolyline = [[FNLine alloc] initWithPoints:self.activePointAnns];
    [self.mapView addOverlay:self.activePolyline.overlay];
}

- (void)updatePoint
{
    FNPoint* p = [[FNPoint alloc] init];
    
    CLLocationCoordinate2D c = [self.activePoints[0] MKCoordinateValue];    
    p.coordinate = c;
    
    [self.activePoints removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FNMapViewControllerDidCreateNewEntity object:p];
    
    [self.currentAnnotations addObject:p];
    [self.mapView addAnnotation:p];
}

- (void)updatePhoto
{
    if (self.chosenImage) {
        FNPoint* p = [[FNPoint alloc] init];
        NSURL* photoURL = [[FNDataManager sharedManager] saveImage:self.chosenImage];
        
        p.photoURL = photoURL;
        
        CLLocationCoordinate2D c = [self.activePoints[0] MKCoordinateValue];
        p.coordinate = c;
        
        [self.activePoints removeAllObjects];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FNMapViewControllerDidCreateNewEntity object:p];
        
        [self.currentAnnotations addObject:p];
        [self.mapView addAnnotation:p];
    }
}

- (id<FNEntity>)entityForPolygonView:(MKPolygonView *)polygonView
{
    MKPolygon* polygon = polygonView.polygon;
    for (FNCard* card in self.currentCaseFile.cards) {
        for (id<FNEntity> entity in card.entities) {
            if ([entity isKindOfClass:[FNShape class]]) {
                FNShape* shape = (FNShape *)entity;
                if ([shape.overlay isEqual:polygon]) {
                    return shape;
                }
            }
        }
    }
    
    return nil;
}

- (void)didSelectPolygonView:(MKPolygonView *)polygonView
{
    id<FNEntity> entity = [self entityForPolygonView:polygonView];
    if (entity) {
        [self didSelectEntity:entity];
    }
}

- (void)handlePolygonSelectionWithRecognizer:(UITapGestureRecognizer *)recognizer
{
    MKPolygonView *tappedOverlay = nil;
    int i = 0;
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        MKPolygonView *view = (MKPolygonView *)[self.mapView viewForOverlay:overlay];
        
        if (view){
            CGPoint touchPoint = [recognizer locationInView:self.mapView];
            CLLocationCoordinate2D touchMapCoordinate =
            [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
            
            MKMapPoint mapPoint = MKMapPointForCoordinate(touchMapCoordinate);
            
            CGPoint polygonViewPoint = [view pointForMapPoint:mapPoint];
            if(CGPathContainsPoint(view.path, NULL, polygonViewPoint, NO)){
                tappedOverlay = view;
                tappedOverlay.tag = i;
                tappedOverlay.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
                [self didSelectPolygonView:tappedOverlay];
                break;
            } else {
                view.fillColor = UNSELECTED_FILL;
            }
        }
        i++;
    }
    
}

- (void)didTapMapView:(UITapGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateEnded) {

        CGPoint point = [sender locationInView:self.mapView];
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        
        
        [self handlePolygonSelectionWithRecognizer:sender];
        
        if (self.polygonModeSelected || self.polylineModeSelected || self.pointModeSelected || self.photoModeSelected) {
            NSValue* locationObject = [NSValue valueWithMKCoordinate:coordinate];
            [self.activePoints addObject:locationObject];
        }
        
        if (self.polylineModeSelected) {
            [self updatePolyline];
        }
        
        if (self.polygonModeSelected) {
            [self updatePolygon];
        }
        
        if (self.pointModeSelected) {
            [self updatePoint];
        }
        
        if (self.photoModeSelected) {
            [self updatePhoto];
        }
        
        //MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
        //CGPoint linePoint = [self.activePolygonView pointForMapPoint:mapPoint];
        //NSLog(@"points:%@ %f %f", locationObject, location.latitude, location.longitude);
    }
}

@end
