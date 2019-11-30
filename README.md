<img src="Earbuddy/Resources/Assets.xcassets/AppIcon.appiconset/128.png"/>

# Earbuddy

Bluetooth earbud connection helper for macOS

Specifically designed for solving one of macOS Catalina 10.15.1 Bluetooth issues. After a while using a earbud,
sometimes Output Audio Device switches to Internal Speakers and it fails to change it back to your bluetooth device.
The only solution known is disconnecting an reconnecting earbud.

Earbuddy does that for you! It subscribes to audio ouput device change event and it disconnects and reconnects if it is
different from your selected device. Beware that it will do that if you change output device manually too, so do not 
forget to turn "Force as output" option off if you want to change the output source.


## Usage

1) Select your Paired Bluetooth Device from settings
<img src="Screenshots/Screen%20Shot%202019-11-20%20at%2022.12.14.png" width="400"/>
<img src="Screenshots/Screen%20Shot%202019-11-20%20at%2022.06.35.png" width="400"/>

2) Enable "Force as output" option

<img src="Screenshots/Screen%20Shot%202019-11-20%20at%2022.08.03.png" width="400"/>
