## General
  ☐ The app should be able to find all the pieces on the table. When the user taps 'done searching' the app should report which pieces are missing. It can offer to show the pieces to the user.
  ☐ Create an eye-guided menu.
  ☐ Create a UI for detecting if all necessary pieces are on the scene.
  ☐ Create a wireframe.
    ☐ When the app turns on it requests needed permissions from the user.
    ☐ Then it informs the user that it will need to scan the area (e.g. table) where the user will be building the model on. This will need to show some kind of a percentage.
      ☐ The user should also be informed about the moving of the camera-it will give the app a much better understanding of the area he's building his/hers models.
        ☐ We could offer to save that map for future use (it will make recognition process much more accurate).
    The following should happen for each building stage [BUILDING STAGES CAN BE SELECTED FROM THE MENU]:
      ☐ When the scan is done, the app asks the user to scatter all of the needed pieces on the work surface.
      ☐ Once the user taps confirms all of the pieces he/she has are there, the app scans the surface until it finds all of the pieces (the progress bar should be showing along with 'too dark to scan' and similar warnings the scanning app has) or until 30 seconds pass (the timer should also be visible).
        ☐ If the timer is done and not all of the pieces are found, the user is prompted to continue scanning if if the app didn't manage to recognize all of the pieces OR if he choses 'Those are all I have' the app can display the missing pieces as 3D models (or project them onto the surface).







# Protean-X iOS App
[![CircleCI](https://circleci.com/gh/nascentcorp/protean-x.svg?style=shield&circle-token=3c9251a1841cc2b5f8f61cf68a4877451a2e19fc)](https://circleci.com/gh/nascentcorp/protean-x)

## About

Next gen Protean App with Clean Architecture.

## Requirements

* Xcode 9.0+
* Swift 4.0

* iOS 10.0+

## Installation

After you've checked out the code, you should be able to build and run it. Make sure you open the **workspace** and not the **project** file as XCode will complain about missing Frameworks and the app will not build.

The project uses cocapods dependencies but they are added to source control and using them should not require additional steps. If, by any chance, your project fails to run on their account, make sure to re-install all of the cocoapods (ensure you have the appropriate/latest cocoapods version):

```
> pod install
```

If you're not sure what cocoapods are or how to install them, just follow this short guide: https://guides.cocoapods.org/using/getting-started.html

_Note:_ The project also uses [YPDrawSignatureView](https://github.com/GJNilsen/YPDrawSignatureView) which had it's file ```Sources/YPDrawSignatureView.swift```

## CI/CD

Continuous integration/delivery is being handled via CircleCI/Fastlane. For fastlane integration to work, you need to have the following set:

1. Authorized user keys for repository access for both, this project and fastlane match credentials repo.
2. The following environment variables set:
  * **SLACK_API_TOKEN** - This is the legacy API token used to upload IPA files to Slack.
  * **SLACK_CHANNEL_NAME** - The Slack channel we're reporting and uploading IPA to.
  * **SLACK_WEBHOOK_URL** - A Slack webhook URL for posting messages to a specific channel.
  * **MATCH_PASSWORD** - A password used to decrypt fastlane match credentials.

After each commit to **develop**:
1. Tests are being run.
2. Patch version is bumped.

After each commit to **master**:
1. Build is being made and enterprise IPA exported.
2. IPA is being uploaded to Slack.
3. Release is tagged.
4. Minor version is bumped.

## Author

* Miran Brajsa

## License

All rights belong to Nascent Corporation (derek at nascentcorp dot com).
