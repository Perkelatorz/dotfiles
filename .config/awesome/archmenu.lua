 local menu98edb85b00d9527ad5acebe451b3fae6 = {
     {"Neovim", "xterm -e nvim ", "/usr/share/icons/hicolor/128x128/apps/nvim.png" },
     {"Picom", "picom", "/usr/share/icons/hicolor/48x48/apps/compton.png" },
     {"Software Token", "stoken-gui", "/usr/share/pixmaps/stoken-gui.png" },
     {"Software Token (small)", "stoken-gui --small", "/usr/share/pixmaps/stoken-gui.png" },
     {"Xarchiver", "xarchiver ", "/usr/share/icons/hicolor/16x16/apps/xarchiver.png" },
     {"wpgtk", "/usr/bin/wpg", "/usr/share/pixmaps/wpgtk.png" },
 }

 local menuc8205c7636e728d448c2774e6a4a944b = {
     {"Avahi SSH Server Browser", "/usr/bin/bssh"},
     {"Avahi VNC Server Browser", "/usr/bin/bvnc"},
     {"Firefox", "/usr/lib/firefox/firefox ", "/usr/share/icons/hicolor/16x16/apps/firefox.png" },
 }

 local menue6f43c40ab1c07cd29e4e83e4ef6bf85 = {
     {"Icon Browser", "yad-icon-browser", "/usr/share/icons/hicolor/16x16/apps/yad.png" },
     {"Meld", "meld "},
 }

 local menu52dd1c847264a75f400961bfb4d1c849 = {
     {"Qt V4L2 test Utility", "qv4l2", "/usr/share/icons/hicolor/16x16/apps/qv4l2.png" },
     {"Qt V4L2 video capture utility", "qvidcap", "/usr/share/icons/hicolor/16x16/apps/qvidcap.png" },
     {"Volume Control", "pavucontrol"},
 }

 local menuee69799670a33f75d45c57d1d1cd0ab3 = {
     {"Avahi Zeroconf Browser", "/usr/bin/avahi-discover"},
     {"EndeavourOS Quickstart Installer", "eos-quickstart"},
     {"EndeavourOS apps info", "eos-apps-info", "/usr/share/pixmaps/endeavouros-icon.png" },
     {"EndeavourOS log tool", "/usr/bin/eos-log-tool", "/usr/share/pixmaps/endeavouros-icon.png" },
     {"File Manager PCManFM", "pcmanfm "},
     {"Reflector Simple", "/usr/bin/reflector-simple", "/usr/share/pixmaps/endeavouros-icon.png" },
     {"UXTerm", "uxterm", "/usr/share/pixmaps/xterm-color_48x48.xpm" },
     {"Welcome", "eos-welcome --once", "/usr/share/pixmaps/endeavouros-icon.png" },
     {"XTerm", "xterm", "/usr/share/pixmaps/xterm-color_48x48.xpm" },
     {"eos-update", "xterm -e bash -c \"echo '==> eos-update --yay'; eos-update --yay; eos-sleep-counter 60\"", "/usr/share/pixmaps/endeavouros-icon.png" },
     {"kitty", "kitty", "/usr/share/icons/hicolor/256x256/apps/kitty.png" },
 }

xdgmenu = {
    {"Accessories", menu98edb85b00d9527ad5acebe451b3fae6},
    {"Internet", menuc8205c7636e728d448c2774e6a4a944b},
    {"Programming", menue6f43c40ab1c07cd29e4e83e4ef6bf85},
    {"Sound & Video", menu52dd1c847264a75f400961bfb4d1c849},
    {"System Tools", menuee69799670a33f75d45c57d1d1cd0ab3},
}

