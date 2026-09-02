function assignRole(window) {
    if (window.caption === "AR Desktop") {
        window.keepBelow = true;
        window.skipTaskbar = true;
        window.skipPager = true;
        window.onAllDesktops = true;
    } else if (window.caption === "AR Top Bar" || window.caption === "AR Dock"
               || window.caption === "AR Quick Controls") {
        window.keepAbove = true;
        window.skipTaskbar = true;
        window.skipPager = true;
        window.onAllDesktops = true;
    } else if (window.caption === "AR Launcher") {
        window.keepAbove = true;
        window.skipTaskbar = true;
        window.skipPager = true;
        window.onAllDesktops = true;
    }
}

workspace.windowList().forEach(assignRole);
workspace.windowAdded.connect(assignRole);

