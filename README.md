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
