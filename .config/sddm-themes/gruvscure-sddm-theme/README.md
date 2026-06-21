# gruvscure-sddm-theme

A flat, square, Gruvbox-dark inspired spin of [`saatvik333/obscure-sddm-theme`](https://github.com/saatvik333/obscure-sddm-theme).
and come with vim style navigation```h``` ```j``` to switch desktops sessions & ```/``` for toggle focus on password input

![Theme preview](preview.png)

This variant removes the rounded dark look in minimal session-manager

## Requirements

- SDDM with Qt 6 greeter support
- `qt6-5compat`
- a font installed on the target system that matches `fontFamily` in `theme.conf`

## Manual Install

Clone the repo:

```bash
git clone https://github.com/SUDOER1337/gruvscure-sddm-theme.git
cd gruvscure-sddm-theme
```

Preview locally (must be in the repo folder):

```bash
sddm-greeter-qt6 --test-mode --theme "$PWD"
```

Install the theme:

```bash
sudo mkdir -p /usr/share/sddm/themes/gruvscure-sddm-theme
sudo cp -r Main.qml metadata.desktop theme.conf assets /usr/share/sddm/themes/gruvscure-sddm-theme/
```

Activate it by creating ```sddm.conf.d``` using tee to set "Current=":

```bash
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null <<'EOF'
[Theme]
Current=gruvscure-sddm-theme
EOF
```

If SDDM launches an on-screen keyboard and you do not want it, set an empty input method:

```bash
sudo tee /etc/sddm.conf.d/20-inputmethod.conf >/dev/null <<'EOF'
[General]
InputMethod=
EOF
```

## Configuration

All user-facing customization lives in `theme.conf`.

### Core Colors

| Key | Description | Default |
| --- | --- | --- |
| `backgroundColor` | Full-screen background color behind everything | `#1d2021` |
| `panelColor` | Main login panel background | `#282828` |
| `textColor` | Primary text color | `#ebdbb2` |
| `errorColor` | Error flash color | `#fb4934` |
| `activeColor` | Accent used for active emphasis | `#d79921` |

### Control Colors

| Key | Description | Default |
| --- | --- | --- |
| `controlFillBaseColor` | Default input / selector / button fill | `#32302f` |
| `controlFillHoverColor` | Hover fill | `#3c3836` |
| `controlFillFocusColor` | Focused password field fill | `#504945` |
| `controlFillPressedColor` | Pressed state fill | `#282828` |

### Behavior

| Key | Description | Default |
| --- | --- | --- |
| `fontFamily` | UI font family | `JetBrainsMono Nerd Font` |
| `baseFontSize` | Base font size in pixels | `14` |
| `sessionsFontSize` | Session selector font size in pixels | `15` |
| `controlCornerRadius` | Corner radius for controls and panel | `0` |
| `showUserSelector` | Show user selector carousel | `false` |
| `showSessionSelector` | Show session selector | `true` |
| `autoFocusPassword` | Focus password field on load | `true` |
| `useIpaMask` | Use upstream IPA masking mode | `false` |
| `simpleMaskChar` | Mask character when IPA masking is off | `*` |
| `randomizePasswordMask` | Randomize IPA masking output | `false` |

### Background Image

| Key | Description | Default |
| --- | --- | --- |
| `backgroundImage` | Optional wallpaper path | _(empty)_ |
| `backgroundFillMode` | `aspectCrop`, `aspectFit`, `stretch`, `tile`, `center` | `aspectCrop` |
| `backgroundOpacity` | Wallpaper opacity from 0-100 | `100` |
| `backgroundGlassEnabled` | Blur the wallpaper layer | `false` |
| `backgroundGlassIntensity` | Blur intensity from 0-100 | `0` |
| `backgroundTintColor` | Overlay tint applied on top of wallpaper | `#1d2021` |
| `backgroundTintIntensity` | Tint opacity from 0-100 | `0` |

## Notes

- `Theme-Id` is `gruvscure-sddm-theme`, so the SDDM install directory and `Current=` value should match that exactly.

## License

This project remains under the MIT License. See [LICENSE](LICENSE).
