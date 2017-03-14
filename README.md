# OCRAI

Optical Character Recognition Artificial Intelligence iOS app for Udacity nanodegree.

## API Configuration

API services such as Google Vision and Monkey Learn require credentials for access. The exact credentials depends on each service. Usually this entails registering for an account, and acquiring a key or authorization token. The credentials are not included in this repository as doing so presents a security risk. Instructions for each service follow below. Please check the documentation for the relevant service for more details.

### Google Vision & Google Natural Language

1. Follow the instructions for "Setup an API key" here: https://cloud.google.com/natural-language/docs/common/auth.
Note: The API key should not be restricted.
2. In the XCode project, copy or rename "google-api-config.default.plist" to "google-api-config.plist".
3. Edit the file from step 2, and enter the Google API key for the "key" field.

### Monkey Learn

1. Login to MonkeyLearn here: http://monkeylearn.com/
2. Find the API Token under the "API Keys" section under "My Account". https://app.monkeylearn.com/main/my-account/tab/api-keys/
3. In the XCode project, copy or rename "monkeylearn-api-config.default.plist" to "monkeylearn-api-config.plist".
4. Edit the plist file from step 3, and enter the API token for the "authorizationToken" field.

## TODO

### Essential

- Enable camera / photo library buttons only when functionality is available.
- Normalize image orientation when taking photo and importing.
- Color image card according to type (person, organization, event, etc).
- Include postal addresses in exported contact.
- Prompt to overwrite when scanning over existing information.
- Resize image to 1024x768 for uploading.

### Nice to have

- Only use single derived value for each line of text. Don't re-scan line of text if already tagged. I.e. Don't tag "Sandy Bay" as organization if already tagged as an address.
- Search: Name, organization, phone number.
- iPad layout: Grid documents list. Show document as model popover, or side detail view.
- Continue scanning in background when switching back to list from detail view.
- Improve editing: Remove modal edit/done state. Tap on textfield to edit. Enter to save. Always show blank textfield - adding text and entering saves data and creates new blank textfield.
- Improve organization name detection: Check remaining text for nouns, after name detection.
- Pre-process scanned image: Histogram balance.
- Scan raw / uncompressed image data (avoid JPEG artifacts).
- Support additional services: Haven, Tesseract.
- Extract date information, tag fragments with dates, as event type.
- Extract faces from scanned image.
- Extract machine codes (QR code, bar code) from scanned image.
- Extract logos from scanned image.
- 3D touch shortcut actions: Take photo,
- App extension: Scan image from photos app (import into scanner app).
