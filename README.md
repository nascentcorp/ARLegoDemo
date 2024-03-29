# AR Lego Demo

## About

The AR Lego Demo app is intended to guide a user from one building step to another by helping him/her identifying all of the needed pieces on the table and displaying a virtual model of the finished building step with those pieces fitted in.

## Application flow

* When The app turns on it needs to request all of the permissions needed e.g. camera etc.
* After the permissions are given, it should inform the user that it will need to scan the area (e.g. table) where the user will be building the model on. This will need to show some kind of a percentage.
* The user should also be informed about the moving of the camera. It will give the app a much better understanding of the area he's building his/hers models.
  * We could offer to save that map for future use (it will make recognition process much more accurate) **[upgrade]**.

### The following should happen for each building stage **[BUILDING STAGES CAN BE SELECTED FROM THE MENU]**
* When the surface scan is done, the app asks the user to scatter all of the needed pieces on the work surface.
* Once the user taps confirms all of the pieces he/she has are there, the app scans the surface until it finds all of the pieces (the progress bar should be showing along with 'too dark to scan' and similar warnings the scanning app has) or until 30 seconds pass (the timer should also be visible).
  * If the timer is done and not all of the pieces are found, the user is prompted to continue scanning if if the app didn't manage to recognize all of the pieces OR he/she can chose the 'Those are all I have' option.
* If the scan is unsuccessful the app can display the missing pieces as 3D models (or project them onto the surface) and ask the user to search for the models to continue with the current stage. It can also suggest that the user choses a different stage if he/she is on the wrong one (too far ahead).
* If the scan is successful the app can display a 3D/projected model of the model being built OR it can scan for the model in the current building stage on the work surface (a 30 second timer should be implemented just as was the case with searching building blocks).
  * If the timer is done and the model was not recognized we could ask the user to try again or to switch to a plain 3D model for display.
* If the model scan was successful we can project a 3D model over the one being scanned OR on the work surface and display an animation which puts all of the missing pieces together.
  * Each of the piece-fitting animations should be able to repeated individually with object being rotated as appropriate (for better viewing angle).

### Optional development:
* Eye-navigated option tap/selection
* An animation of blinking border around a model being found (something like a targeting animation in Final Fantasy: The Spirits Within movie).

## Requirements

* Xcode 10.0+
* Swift 4.2+

* iOS 12.0+

## Installation

After you've checked out the code, you should be able to build and run it.

## Author

* Miran Brajsa

## License

All rights belong to Nascent Corporation (derek at nascentcorp dot com).
