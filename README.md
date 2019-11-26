# Eventure-iOS
iOS Frontend for the Eventure app. App store link: https://apps.apple.com/app/id1478542362.

## Get Started
- Make sure you have [CocoaPods](https://cocoapods.org "Official site for CocoaPods") installed.
- Navigate to the project directory in Terminal, and run `pod install`.
- Open `Eventure.workspace` in Xcode. 

## Guidelines
Here are a few guidelines that you should follow when contributing.
1. Include documentation for every defined function.
2. Refrain from using `MainMenu.storyboard`.
3. Use abstraction and minimize scope (e.g. use `private func` instead of `func` when appropriate).
4. Make sure that you *never* include our login credentials in `Global Constants.swift`!

Happy coding!

## Some current features
- **QR Code check-in**: No more google forms!
    - Attendance records (can be exported as CSV)
- **Digital ticketing system**: Create and distribute tickets in Eventure. No need to worry about bookkeeping. Verify tickets by scanning QR codes from your guests using Eventure (logged in with your organizational acount).
- Students can view their ticket and purchase details. Currently transactions are unavailable through Eventure, so organizations should first check that their attendees have payed before issuing the tickets.
  - Tickets can be set to *transferable*, meaning that a ticket owner can transfer a ticket to another account, provided that both account owners agree with the transfer.
- **Personalized event recommendation** based on interests.
- Receive **real-time updates** from organizations which you have subscribed, and from events which you have expressed interest.
- **Event statistic**: See beautiful visual representation of your club's past success.
- Organizations can easily publish and modify event posts, or save them as drafts.
