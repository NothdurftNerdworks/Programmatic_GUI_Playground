# Programmatic_GUI_Playground
 Programmatic GUIs for demonstration and testing against other MATLAB projects.

## Background
MATLAB provides an interface, historically GUIDE and more recently AppDesigner, for building GUIs in a visual environment. These apps are a good starting grounds for many basic applications, but impose a framework often unsuited for more elaborate programs. As a result, developers often migrate to programmatic GUI development over time.

When building out MATLAB tools like [bfish](https://github.com/NothdurftNerdworks/bfish) I've found myself needing to test the core functionality against a robust GUI. However, building out said GUI was outside the scope of the original project. As a result, like many developers, I'd throw a few lines together for testing like:

```Matlab
f = uifigure("Name", "one", "Visible", "off");
pb = uibutton(f, "Text", "two");
```

At the same time, I've often coded-up small stubs to demo various GUI features, or to work out (*imho*) the most efficient mechanism for defining reusable codeblocks for particular features. Towards project end these bits would generally get thrown in an 'archive' folder, rarely to see the light of day again.

## Purpose
[**Programmatic_GUI_Playground**](https://github.com/NothdurftNerdworks/Programmatic_GUI_Playground) is intended to serve two purposes:
1. As POCs for interesting/useful features.
2. As working examples to test new applications against.
