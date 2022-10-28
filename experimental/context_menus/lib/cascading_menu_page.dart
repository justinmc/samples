import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'platform_selector.dart';
/// An enhanced enum to define the available menus and their shortcuts.
///
/// Using an enum for menu definition is not required, but this illustrates how
/// they could be used for simple menu systems.
enum MenuEntry {
  about('About'),
  showMessage(
      'Show Message', SingleActivator(LogicalKeyboardKey.keyS, control: true)),
  hideMessage(
      'Hide Message', SingleActivator(LogicalKeyboardKey.keyS, control: true)),
  colorMenu('Color Menu'),
  colorRed('Red Background',
      SingleActivator(LogicalKeyboardKey.keyR, control: true)),
  colorGreen('Green Background',
      SingleActivator(LogicalKeyboardKey.keyG, control: true)),
  colorBlue('Blue Background',
      SingleActivator(LogicalKeyboardKey.keyB, control: true));

  const MenuEntry(this.label, [this.shortcut]);
  final String label;
  final MenuSerializableShortcut? shortcut;
}

class MyContextMenu extends StatefulWidget {
  const MyContextMenu({super.key, required this.message});

  final String message;

  @override
  State<MyContextMenu> createState() => _MyContextMenuState();
}

class _MyContextMenuState extends State<MyContextMenu> {
  MenuEntry? _lastSelection;
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  final MenuController _menuController = MenuController();
  ShortcutRegistryEntry? _shortcutsEntry;

  Color get backgroundColor => _backgroundColor;
  Color _backgroundColor = Colors.red;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      setState(() {
        _backgroundColor = value;
      });
    }
  }

  bool get showingMessage => _showingMessage;
  bool _showingMessage = false;
  set showingMessage(bool value) {
    if (_showingMessage != value) {
      setState(() {
        _showingMessage = value;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dispose of any previously registered shortcuts, since they are about to
    // be replaced.
    _shortcutsEntry?.dispose();
    // Collect the shortcuts from the different menu selections so that they can
    // be registered to apply to the entire app. Menus don't register their
    // shortcuts, they only display the shortcut hint text.
    final Map<ShortcutActivator, Intent> shortcuts =
        <ShortcutActivator, Intent>{
      for (final MenuEntry item in MenuEntry.values)
        if (item.shortcut != null)
          item.shortcut!: VoidCallbackIntent(() => _activate(item)),
    };
    // Register the shortcuts with the ShortcutRegistry so that they are
    // available to the entire application.
    _shortcutsEntry = ShortcutRegistry.of(context).addAll(shortcuts);
  }

  @override
  void dispose() {
    _shortcutsEntry?.dispose();
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CascadingMenu(
        menuPosition: Offset.zero,
        alignmentOffset: Offset.zero,
        clipBehavior: Clip.none,
        orientation: Axis.vertical,
        menuChildren: <Widget>[
          MenuItemButton(
            child: Text(MenuEntry.about.label),
            onPressed: () => _activate(MenuEntry.about),
          ),
          if (_showingMessage)
            MenuItemButton(
              onPressed: () => _activate(MenuEntry.hideMessage),
              shortcut: MenuEntry.hideMessage.shortcut,
              child: Text(MenuEntry.hideMessage.label),
            ),
          if (!_showingMessage)
            MenuItemButton(
              onPressed: () => _activate(MenuEntry.showMessage),
              shortcut: MenuEntry.showMessage.shortcut,
              child: Text(MenuEntry.showMessage.label),
            ),
          SubmenuButton(
            menuChildren: <Widget>[
              MenuItemButton(
                onPressed: () => _activate(MenuEntry.colorRed),
                shortcut: MenuEntry.colorRed.shortcut,
                child: Text(MenuEntry.colorRed.label),
              ),
              MenuItemButton(
                onPressed: () => _activate(MenuEntry.colorGreen),
                shortcut: MenuEntry.colorGreen.shortcut,
                child: Text(MenuEntry.colorGreen.label),
              ),
              MenuItemButton(
                onPressed: () => _activate(MenuEntry.colorBlue),
                shortcut: MenuEntry.colorBlue.shortcut,
                child: Text(MenuEntry.colorBlue.label),
              ),
            ],
            child: const Text('Background Color'),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(50),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        child: MenuAnchor(
          controller: _menuController,
          anchorTapClosesMenu: true,
          menuChildren: <Widget>[
            MenuItemButton(
              child: Text(MenuEntry.about.label),
              onPressed: () => _activate(MenuEntry.about),
            ),
            if (_showingMessage)
              MenuItemButton(
                onPressed: () => _activate(MenuEntry.hideMessage),
                shortcut: MenuEntry.hideMessage.shortcut,
                child: Text(MenuEntry.hideMessage.label),
              ),
            if (!_showingMessage)
              MenuItemButton(
                onPressed: () => _activate(MenuEntry.showMessage),
                shortcut: MenuEntry.showMessage.shortcut,
                child: Text(MenuEntry.showMessage.label),
              ),
            SubmenuButton(
              menuChildren: <Widget>[
                MenuItemButton(
                  onPressed: () => _activate(MenuEntry.colorRed),
                  shortcut: MenuEntry.colorRed.shortcut,
                  child: Text(MenuEntry.colorRed.label),
                ),
                MenuItemButton(
                  onPressed: () => _activate(MenuEntry.colorGreen),
                  shortcut: MenuEntry.colorGreen.shortcut,
                  child: Text(MenuEntry.colorGreen.label),
                ),
                MenuItemButton(
                  onPressed: () => _activate(MenuEntry.colorBlue),
                  shortcut: MenuEntry.colorBlue.shortcut,
                  child: Text(MenuEntry.colorBlue.label),
                ),
              ],
              child: const Text('Background Color'),
            ),
          ],
          child: Container(
            alignment: Alignment.center,
            color: backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Ctrl-click anywhere on the background to show the menu.'),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    showingMessage ? widget.message : '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Text(_lastSelection != null
                    ? 'Last Selected: ${_lastSelection!.label}'
                    : ''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _activate(MenuEntry selection) {
    setState(() {
      _lastSelection = selection;
    });
    switch (selection) {
      case MenuEntry.about:
        showAboutDialog(
          context: context,
          applicationName: 'MenuBar Sample',
          applicationVersion: '1.0.0',
        );
        break;
      case MenuEntry.showMessage:
      case MenuEntry.hideMessage:
        showingMessage = !showingMessage;
        break;
      case MenuEntry.colorMenu:
        break;
      case MenuEntry.colorRed:
        backgroundColor = Colors.red;
        break;
      case MenuEntry.colorGreen:
        backgroundColor = Colors.green;
        break;
      case MenuEntry.colorBlue:
        backgroundColor = Colors.blue;
        break;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.controlLeft) &&
        !HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.controlRight)) {
      return;
    }
    _menuController.open(position: details.localPosition);
  }
}

class CascadingMenuPage extends StatelessWidget {
  const CascadingMenuPage({
    super.key,
    required this.onChangedPlatform,
  });

  static const String kMessage = '"Talk less. Smile more." - A. Burr';
  static const String route = 'cascading-menu';
  static const String title = 'Cascading Menu Example';
  static const String subtitle = 'Shows how to create a context menu with submenus.';

  final PlatformCallback onChangedPlatform;

  static const String url = '$kCodeUrl/cascading_menu_page.dart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(CascadingMenuPage.title),
        actions: <Widget>[
          PlatformSelector(
            onChangedPlatform: onChangedPlatform,
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () async {
              if (!await launchUrl(Uri.parse(url))) {
                throw 'Could not launch $url';
              }
            },
          ),
        ],
      ),
      body: const MyContextMenu(message: kMessage),
    );
  }
}





/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'platform_selector.dart';

class CascadingMenuPage extends StatelessWidget {
  const CascadingMenuPage({
    Key? key,
    required this.onChangedPlatform,
  }) : super(key: key);

  static const String route = 'cascading-menu';
  static const String title = 'Cascading Menu Example';
  static const String subtitle = 'Shows how to create a context menu with submenus.';

  final PlatformCallback onChangedPlatform;

  static const String url = '$kCodeUrl/cascading_menu_page.dart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(CascadingMenuPage.title),
        actions: <Widget>[
          PlatformSelector(
            onChangedPlatform: onChangedPlatform,
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () async {
              if (!await launchUrl(Uri.parse(url))) {
                throw 'Could not launch $url';
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 400.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              MenuThing(),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuThing extends StatefulWidget {
  const MenuThing({
    super.key,
  });

  @override
  State<MenuThing> createState() => _MenuThingState();
}

class _MenuThingState extends State<MenuThing> {
  DialogRoute _showDialog (BuildContext context, String message) {
    return DialogRoute<void>(
      context: context,
      builder: (BuildContext context) =>
        AlertDialog(title: Text(message)),
    );
  }

  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  ShortcutRegistryEntry? _shortcutsEntry;

  Color get backgroundColor => _backgroundColor;
  Color _backgroundColor = Colors.red;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      setState(() {
        _backgroundColor = value;
      });
    }
  }

  bool get showingMessage => _showingMessage;
  bool _showingMessage = false;
  set showingMessage(bool value) {
    if (_showingMessage != value) {
      setState(() {
        _showingMessage = value;
      });
    }
  }

  void _onPressedAbout() {
    ContextMenuController.removeAny();
    Navigator.of(context).push(_showDialog(context, 'You pressed "about".'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dispose of any previously registered shortcuts, since they are about to
    // be replaced.
    _shortcutsEntry?.dispose();
    // Collect the shortcuts from the different menu selections so that they can
    // be registered to apply to the entire app. Menus don't register their
    // shortcuts, they only display the shortcut hint text.
    final Map<ShortcutActivator, Intent> shortcuts =
        <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.keyA, meta: true): VoidCallbackIntent(_onPressedAbout),
    };
    // Register the shortcuts with the ShortcutRegistry so that they are
    // available to the entire application.
    _shortcutsEntry = ShortcutRegistry.of(context).addAll(shortcuts);
  }

  @override
  void dispose() {
    _shortcutsEntry?.dispose();
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      menuChildren: <Widget>[
        MenuItemButton(
          onPressed: _onPressedAbout,
          child: const Text('About'),
        ),
        SubmenuButton(
          menuChildren: <Widget>[
            MenuItemButton(
              onPressed: () => {},
              shortcut: MenuEntry.colorRed.shortcut,
              child: Text(MenuEntry.colorRed.label),
            ),
            MenuItemButton(
              onPressed: () => {},
              shortcut: MenuEntry.colorGreen.shortcut,
              child: Text(MenuEntry.colorGreen.label),
            ),
            MenuItemButton(
              onPressed: () => {},
              shortcut: MenuEntry.colorBlue.shortcut,
              child: Text(MenuEntry.colorBlue.label),
            ),
          ],
          child: const Text('Background Color'),
        ),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return TextButton(
          focusNode: _buttonFocusNode,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: const Text('OPEN MENU'),
        );
      },
    );
  }
}
*/
