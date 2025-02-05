---
layout: single
title:  "Authenticating Users with Blizzard on iOS"
date:   2021-09-30 16:05:45 -0800
categories: iOS
tags: swift ios blizzard security privacy gaming apple
---
When I initially developed Hearth Keeper, I asked users to create an account with me or use social logins. While this worked and was certainly an acceptable approach, it required me to ask for personal information from my users, like their email, which I had no need of other than for the sake of creating an account. Soon after, I discovered the [Blizzard APIs](https://dev.battle.net/). Using their OAuth APIs, I could authenticate users for my service without asking for any personal information from users and without requiring them to create another yet account. Using Blizzard’s own services also served as reassurance to my users that Blizzard was aware of my service and everything I was doing was within their terms of service. While there was no official Hearthstone API at the time, Blizzard introduced [one](https://develop.battle.net/documentation/hearthstone) some time later and having users pre-authenticated through Blizzard allowed me to jump straight in, eventually leading me to write [HearthstoneKit](https://github.com/StarLard/HearthstoneKit).

# Get Registered
The first step to using the APIs is to get registered with Blizzard’s developer program, if you haven’t already. Make sure that your app is listed under the applications tab of your account profile and that you’ve been given the corresponding key and secret. If you haven’t worked with APIs before, these are how your app will identify itself to Blizzard when making calls to the API. It is your responsibility to handle these securely. I’m not going to get into that, as security is its own can of worms and there are plenty of articles on the subject available elsewhere. Let it suffice to say that you should not store these keys anywhere publicly viewable, i.e. your public git repository, and that mishandling of the keys can result in Blizzard [revoking your credentials](https://dev.battle.net/policy).

# The Flow
The main authorization flow is similar across all platforms and available in the official documentation [here](https://dev.battle.net/docs/read/oauth). My focus is how this process plays out on iOS and therefore I’m only going to talk about the API flow very briefly. The main steps are as follows:
1. Make an authorization code request to the API with your credentials and what data you need permissions for. There are several parameters to specify here, but for the purposes of this article the main one we are concerned about here is the redirect URI.
1. Exchange your auth code for an access token. Be aware that the token will expire in 30 days or if the user changes their password. Cache any information that makes sense to cache so you can avoid needing to reauthorize the user.
1. Use the access token to make a call to the Community OAuth Profile APIs and retrieve the players unique ID and Battletag. You can use this information to log the user into your service.

# Strategy

## Redirect URI
When making your auth code request you’ll need to decide how to direct the user to a browser window and redirect the user back into your app. As mentioned earlier, the main concern for iOS is the redirect URI. This is the parameter of the auth code request that specifies where Blizzard should redirect the browser to after the user finishes signing into their Blizzard account. Note that the redirect URI given in the parameter must match what you have registered on your developer profile with Blizzard. Normally, in iOS we’d like to use a [custom URL scheme](https://developer.apple.com/documentation/uikit/core_app/allowing_apps_and_websites_to_link_to_your_content/communicating_with_other_apps_using_custom_urls) that we can route back into our app. Something like `myapp://login` Unfortunately, Blizzard mandates that redirect URIs must use HTTPS, meaning we can’t use a URL scheme for the redirect. This leaves us with a few options:
- Use a dummy URL and intercept it in the browser
- Use a Universal Link
- Link to a web-service that automatically redirects to your app

## Using a Dummy URL

This method is outlined on the battle.net forums [here](https://us.battle.net/forums/en/bnet/topic/14279007844#post-2). While this approach works, [UIWebView](https://developer.apple.com/documentation/uikit/uiwebview) has since been deprecated and involves implementing your own web view. Additionally, modern approaches have added benefits to the user such as autofilling data and remembering login status.

## Universal Links
One option for setting the redirect URI that will reroute to your app is to use a [universal link](https://developer.apple.com/ios/universal-links/). Universal links require a supporting website, so if your app is a standalone service this may not be the best solution.

## Using a Web Service
For Hearth Keeper, I decided to use a server to handle the redirect. All you need is a simple server running a script that redirects the browser into a URL scheme supported by your app, passing along the authorization result in the URL. You can host your own server somewhere, embed one into your app on localhost, or use something like [OAuth.click](https://github.com/erorus/oauth-redirect). I strongly recommend hosting your own server. If you don’t control the server, you have no way of knowing if your authorization codes are being saved by the site and can result in your credentials being [revoked by Blizzard](https://us.battle.net/forums/en/bnet/topic/20753726613#post-9). For hosting your own server you can run a static site on [AWS](https://aws.amazon.com/) for free or to embed one in your app you can use something like [Swifter](https://github.com/httpswift/swifter).

# Making the Authorization Request
Apple has introduced a number of web authentication tools over the years, but if you don’t plan to support older versions, jump ahead to [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession).

## SFSafariViewController (iOS 9-10)
[SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) gives your users access to the amenities of Safari by sharing cookies and other website data with the browser. It also works out of the box without requiring you to define your own WebView. However, you lose the customizability that comes with defining your own WebView, meaning you won’t be able to intercept a dummy URL from the browser. If you use a web-service to redirect to your app with a URL scheme, you’ll need to register that scheme with your app. In iOS 11 [SFAuthenticationSession](https://developer.apple.com/documentation/safariservices/sfauthenticationsession) was introduced to replace SFSafariViewController for cases where you simply need to log a user into a service, such as we are doing, and should be used instead.
<script src="https://gist.github.com/StarLard/c1e31e52fc1da876949955908c2c51f1.js"></script>
Note: Make sure your view controller conforms to `SFSafariViewControllerDelegate`. When using [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) you’ll have to handle the redirect URI in your app delegate’s `application(_:open:options:)` method.

## SFAuthenticationSession (iOS 11)
[SFAuthenticationSession](https://developer.apple.com/documentation/safariservices/sfauthenticationsession) is specifically designed to handle logging a user into a third-party web-service via an authentication protocol such as OAuth. Users will be prompted for consent via a dialog and upon confirmation are presented with the webpage to login. Like [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller), the Safari instance is run separate from the app so the app has no way of gaining any information from the session, such as user credentials. [SFAuthenticationSession](https://developer.apple.com/documentation/safariservices/sfauthenticationsession) also includes special handling of the redirect URI, meaning you won’t have to register a URL scheme with your app.
<script src="https://gist.github.com/StarLard/3a3420ec664adb83de019fe0295f80a0.js"></script>

## ASWebAuthenticationSession (iOS 12+)
[SFAuthenticationSession](https://developer.apple.com/documentation/safariservices/sfauthenticationsession) was deprecated one short year after its introduction and replaced with [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession) in iOS 12. It operates nearly identically except that control is given to the user whether to use their existing log-in session from Safari or not.
<script src="https://gist.github.com/StarLard/567585c3c11efd7cd16efe9a2433ca5b.js"></script>

# Conclusion
While it does take a little time to get off the ground with the [Blizzard APIs](https://dev.battle.net/), if you plan on supporting data for their games it can be a worthy investment. Hopefully this article was helpful or, at the very least, a good read!