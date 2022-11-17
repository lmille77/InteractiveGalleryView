# Interactive Gallery View

## Description

A custom UIScrollView that facilitates a focused view for an image. The interactive gallery view can used in conversation
lists, user lists, and more. The interactive gallery view contributes to the user having a seemless experience when
interacting with an application.

## Features
- Draggable image view that can be panned horizontally or vertically. Once released, 
  the draggable image view recenters itself on the screen.
  
- As the panned image view gets closer to the edge of screen, the background view's alpha value updates.
  This creates an animation where the background appears to become more transparent as the image view gets
  closer to the edge of the screen.
  
- The image view is zoomable. A user can either pinch to zoom or double tap to zoom.

- Fast swipe dismisses the interactive gallery view.

## Implementation
- In order to implement, a user needs to create a custom UIViewController that will contain the interactive gallery
  view object and set constraints to interactive gallery view. The draggable image view is coupled within the interactive
  gallery view.

- To set the draggable image view when creating an interactive gallery view, use the 
  setImageView(image : UIImage, width : CGFloat, height : CGFloat) or setImageView(image : UIImage) function.


