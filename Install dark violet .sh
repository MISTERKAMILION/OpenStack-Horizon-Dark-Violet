#!/usr/bin/env bash
# OpenStack Horizon Dark Violet theme for Kolla-Ansible (official method)
#   sudo bash install-dark-violet.sh                 black + violet (default)
#   sudo VARIANT=navy bash install-dark-violet.sh    navy + violet (Horizon UI style)
#   sudo INVENTORY=/path/to/inventory bash install-dark-violet.sh
#   sudo bash install-dark-violet.sh --revert
set -euo pipefail
[ "$(id -u)" -eq 0 ] || exec sudo -E bash "$0" "$@"
say(){ printf '\033[1;35m>> %s\033[0m\n' "$*"; }
THEME=dark-violet; LABEL="Dark Violet"; VARIANT="${VARIANT:-black}"
KCFG=/etc/kolla/config/horizon; SRC="$KCFG/themes/$THEME"
THEME_DIR="/etc/openstack-dashboard/themes/$THEME"
GLOBALS=/etc/kolla/globals.yml; CS="$KCFG/_9999-custom-settings.py"
RUNUSER="${SUDO_USER:-root}"

# ---- find kolla-ansible + inventory (needed for the permanent install) ----
KA="$(command -v kolla-ansible || true)"
[ -n "$KA" ] || KA="$(ls /home/*/kolla-venv/bin/kolla-ansible /home/*/*/bin/kolla-ansible /opt/*/bin/kolla-ansible 2>/dev/null | head -1 || true)"
INV="${INVENTORY:-}"
[ -n "$INV" ] || INV="$(ls /home/*/all-in-one /home/*/multinode /etc/kolla/all-in-one /etc/kolla/multinode 2>/dev/null | head -1 || true)"
reconfigure(){
  if [ -n "$KA" ] && [ -n "$INV" ]; then
    say "kolla-ansible reconfigure -t horizon (inventory: $INV)"
    sudo -u "$RUNUSER" -H env PATH="$(dirname "$KA"):$PATH" "$KA" reconfigure -i "$INV" -t horizon
    return 0
  fi
  return 1
}

strip_blocks(){ for f in "$GLOBALS" "$CS"; do [ -f "$f" ] && sed -i '/# >>> DARKVIOLET/,/# <<< DARKVIOLET/d' "$f" || true; done; }

if [ "${1:-}" = "--revert" ]; then
  say "Reverting"; strip_blocks; rm -rf "$SRC"
  C="$(docker ps --format '{{.Names}}' | grep -x horizon || true)"
  if ! reconfigure && [ -n "$C" ]; then
    docker exec -u root "$C" rm -rf "$THEME_DIR" /etc/openstack-dashboard/local_settings.d/_9999_darkviolet.py
    docker restart "$C"
  fi
  say "Done. Hard-refresh the browser (Ctrl+Shift+R)."; exit 0
fi

# ---- palette ----
if [ "$VARIANT" = navy ]; then
PAL='$s-bg:#0b1437;$s-card:#111c44;$s-card2:#1b254b;$s-text:#ffffff;$s-muted:#a3aed0;$s-accent:#7551ff;$s-accent2:#4318ff;$s-pink:#b86cf0;$s-pinks:#c9b8ff;$s-line:rgba(163,174,208,.16);'
else
PAL='$s-bg:#09030f;$s-card:#120a1f;$s-card2:#1c1030;$s-text:#f4edfc;$s-muted:#a999c4;$s-accent:#a24dff;$s-accent2:#7a1fd1;$s-pink:#f45fc8;$s-pinks:#f8aae7;$s-line:rgba(244,237,252,.13);'
fi
say "Writing theme files ($VARIANT) to $SRC"
rm -rf "$SRC"; mkdir -p "$SRC/static/img"
{ echo "// Dark Violet ($VARIANT)"; echo "$PAL" | tr ';' '\n' | sed 's/$/;/;/^;$/d'; } > "$SRC/static/_variables.scss"
cat >> "$SRC/static/_variables.scss" <<'EOF'
$s-grad:linear-gradient(135deg,$s-accent2,$s-accent 55%,$s-pink);
$brand-primary:$s-accent; $brand-success:#01b574; $brand-info:#4fa3f7; $brand-warning:#ffb547; $brand-danger:#e5484d;
$body-bg:$s-bg; $text-color:$s-text; $headings-color:#fff; $link-color:$s-pinks; $link-hover-color:#fff;
$font-family-sans-serif:"DM Sans","Ubuntu","Segoe UI",system-ui,sans-serif;
$border-radius-base:12px; $border-radius-large:20px; $border-radius-small:8px;
$navbar-height:56px; $navbar-default-bg:$s-bg; $navbar-default-border:$s-line; $navbar-default-color:$s-muted; $navbar-default-link-color:$s-muted; $navbar-default-link-hover-color:#fff;
$panel-bg:$s-card; $panel-default-border:$s-line; $panel-default-heading-bg:$s-card; $panel-footer-bg:$s-card;
$well-bg:$s-card; $well-border:$s-line;
$table-bg:transparent; $table-bg-accent:rgba(255,255,255,.03); $table-bg-hover:rgba($s-accent,.12); $table-border-color:$s-line;
$input-bg:$s-bg; $input-color:$s-text; $input-border:$s-line; $input-border-focus:$s-accent; $input-bg-disabled:$s-card2; $input-group-addon-bg:$s-card2; $input-group-addon-border-color:$s-line;
$dropdown-bg:$s-card; $dropdown-border:$s-line; $dropdown-fallback-border:$s-line; $dropdown-divider-bg:$s-line; $dropdown-link-color:$s-muted; $dropdown-link-hover-color:#fff; $dropdown-link-hover-bg:$s-card2;
$modal-content-bg:$s-card; $modal-content-border-color:$s-line; $modal-header-border-color:$s-line; $modal-footer-border-color:$s-line;
$btn-default-color:$s-text; $btn-default-bg:$s-card2; $btn-default-border:$s-line;
$nav-tabs-border-color:$s-line; $nav-tabs-link-hover-border-color:$s-line; $nav-tabs-active-link-hover-bg:$s-card; $nav-tabs-active-link-hover-color:#fff; $nav-tabs-active-link-hover-border-color:$s-line;
$pagination-bg:$s-card; $pagination-color:$s-muted; $pagination-border:$s-line; $pagination-hover-bg:$s-card2; $pagination-hover-border:$s-line; $pagination-active-bg:$s-accent; $pagination-active-border-color:$s-accent;
$breadcrumb-bg:$s-card; $breadcrumb-color:$s-muted; $breadcrumb-active-color:$s-pinks;
$list-group-bg:$s-card; $list-group-border:$s-line; $list-group-hover-bg:$s-card2;
$hr-border:$s-line; $legend-border-color:$s-line; $gray-lighter:$s-card2; $progress-bg:$s-card2;
$popover-bg:$s-card; $popover-border-color:$s-line; $tooltip-bg:$s-card2;

@import "/themes/default/variables";
EOF
cat > "$SRC/static/_styles.scss" <<'EOF'
@import "/themes/default/styles";
/* ===== Dark Violet: extras on top of the variables (icon fonts are left alone on purpose) ===== */
body{background:radial-gradient(900px circle at 85% -10%,rgba($s-accent,.35),transparent 60%),radial-gradient(700px circle at -5% 100%,rgba($s-accent2,.4),transparent 60%),$s-bg;background-attachment:fixed}
h1,h2,h3,.page-header h1{font-weight:700;letter-spacing:.02em}
h2,.page-header h2{color:$s-pinks;text-transform:uppercase;letter-spacing:.18em;font-size:14px}
.navbar{border-width:0 0 1px 0}
.navbar-brand img,.navbar-header img{height:30px;width:auto;max-width:none}
.navbar a{background:transparent}
.dropdown-menu{border-radius:18px;padding:8px;box-shadow:0 20px 60px -20px #000}
.dropdown-menu>li>a{border-radius:999px}

/* sidebar: transparent, clean pills */
#sidebar,.sidebar,.dash-sidebar,.panel-group{background:transparent;border:0;box-shadow:none}
.panel-group .panel,.panel-group .panel-heading,.panel-group .panel-title,.panel-group .panel-body,.panel-group .list-group,.panel-group .list-group-item{background:transparent !important;border:0 !important;box-shadow:none !important;border-radius:0;margin:0}
.panel-group .panel-title a,.panel-group a[data-toggle="collapse"]{display:block;background:transparent !important;border:0 !important;color:$s-pinks !important;text-transform:uppercase;letter-spacing:.18em;font-size:12px;padding:12px 14px}
.panel-group .panel-body a,.sidebar a,#sidebar a,.nav-stacked>li>a{display:block;background:transparent !important;border:0 !important;color:$s-muted !important;border-radius:999px;padding:9px 16px}
.panel-group .panel-body a:hover,.sidebar a:hover,#sidebar a:hover{color:#fff !important;background:rgba(255,255,255,.07) !important}
.panel-group a.active,.sidebar a.active,#sidebar a.active,.sidebar li.active>a,.nav-pills>li.active>a,.openstack-panel.active a{background:$s-grad !important;color:#fff !important;font-weight:700;box-shadow:0 8px 26px -10px $s-accent}

/* cards, tables, forms, buttons */
.panel,.well,.modal-content{border-radius:20px;box-shadow:0 20px 60px -30px #000}
.breadcrumb{border:1px solid $s-line;border-radius:999px}
.table>thead>tr>th{background:transparent;color:$s-muted;text-transform:uppercase;letter-spacing:.12em;font-size:11px;border-bottom:1px solid $s-line}
.table>tbody>tr>td{font-weight:500}
.form-control,select,input[type=text],input[type=password],input[type=number],input[type=email]{border-radius:999px;height:42px;box-shadow:none}
textarea.form-control{border-radius:18px;height:auto}
.form-control:focus{box-shadow:0 0 0 4px rgba($s-accent,.22)}
label,.control-label{color:$s-muted;text-transform:uppercase;letter-spacing:.12em;font-size:12px}
.btn{border-radius:999px;font-weight:700}
.btn-primary,.btn-success{background:$s-grad;border:0;color:#fff;box-shadow:0 8px 30px -10px $s-accent}
.btn-primary:hover,.btn-primary:focus,.btn-success:hover{background:$s-grad;color:#fff;transform:translateY(-2px)}
.btn-default:hover{border-color:$s-accent}
.label,.badge{border-radius:999px}
.alert,.progress{border-radius:16px}
.progress-bar{background:$s-grad}

/* overview pies -> donuts (dark-mode colour trick, no markup knowledge needed) */
[class*="pie"] svg,[class*="chart"] svg,[data-chart-type] svg{filter:invert(1) hue-rotate(180deg) brightness(1.6);-webkit-mask:radial-gradient(circle closest-side,transparent 54%,#000 55%);mask:radial-gradient(circle closest-side,transparent 54%,#000 55%)}

/* kill ALL white: make every container transparent over a dark page, then re-colour the real components navy */
html{background:$s-bg !important;min-height:100%}
body{min-height:100vh}
body div,body section,body main,body article,body aside,body header,body footer,body form,body fieldset,body table,body thead,body tbody,body tfoot,body tr,body td,body th,body ul,body ol,body li,body dl,body dd,body dt,body p,body pre{background-color:transparent !important;background-image:none !important}
body .table>tbody>tr:nth-of-type(odd)>td{background-color:rgba(27,37,75,.45) !important}
body .table>tbody>tr:hover>td{background-color:#1b254b !important}
body .table>tbody>tr>td a{color:$s-pinks}
body .panel,body .well,body .modal-content,body .popover,body .dropdown-menu,body .datepicker,body .select2-dropdown,body .alert{background-color:#111c44 !important}
body .navbar{background-color:rgba(9,3,15,.94) !important}
body .breadcrumb{background-color:rgba(17,28,68,.6) !important}
body .progress{background-color:#1b254b !important}
body .progress-bar{background-image:$s-grad !important}
body .modal-backdrop{background-color:#000 !important}
body .tooltip-inner{background-color:#1b254b !important}

/* login */
.login .panel,#splash .panel{border-radius:28px;box-shadow:0 30px 80px -30px #000,0 0 80px -30px $s-accent}
img[src*="logo-splash"]{max-width:340px;height:auto;margin:8px auto;display:block}
::-webkit-scrollbar{width:10px;height:10px}::-webkit-scrollbar-thumb{background:$s-accent2;border-radius:999px}::-webkit-scrollbar-track{background:$s-bg}
EOF
cat > "$SRC/static/img/logo.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1100 167" width="190" height="29"><defs><linearGradient id="a" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#f9b6ea"/><stop offset="1" stop-color="#f05fc8"/></linearGradient><linearGradient id="b" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#cc20b6"/><stop offset=".45" stop-color="#a317bd"/><stop offset=".7" stop-color="#7a0cc2"/><stop offset="1" stop-color="#33075c"/></linearGradient></defs><path fill="url(#a)" d="M19,0 H146 A19,19 0 0 1 146,38 H19 A19,19 0 0 1 19,0 Z"/><path fill="url(#b)" d="M20,65 H133 A32,32 0 0 1 165,97 V135 A32,32 0 0 1 133,167 H18.5 A18.5,18.5 0 0 1 18.5,130 H115.5 A12.5,12.5 0 0 0 115.5,105 H20 A20,20 0 0 1 20,65 Z"/><text x="205" y="124" font-family="Ubuntu,'Segoe UI',Arial,sans-serif" font-weight="700" font-size="104" letter-spacing="8" fill="#ffffff">VIOLET</text><text x="670" y="124" font-family="Ubuntu,'Segoe UI',Arial,sans-serif" font-weight="300" font-size="104" letter-spacing="8" fill="#f8aae7">CLOUD</text></svg>
EOF
cp "$SRC/static/img/logo.svg" "$SRC/static/img/logo-splash.svg"
# favicon (needs ImageMagick; skipped with a warning if missing)
cat > /tmp/dark-violet-fav.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 165 167"><rect width="165" height="167" rx="34" fill="#12071f"/><path fill="#f45fc8" d="M19,0 H146 A19,19 0 0 1 146,38 H19 A19,19 0 0 1 19,0 Z" transform="translate(0 20) scale(1 .8)"/><path fill="#a24dff" d="M20,65 H133 A32,32 0 0 1 165,97 V135 A32,32 0 0 1 133,167 H18.5 A18.5,18.5 0 0 1 18.5,130 H115.5 A12.5,12.5 0 0 0 115.5,105 H20 A20,20 0 0 1 20,65 Z" transform="translate(0 4) scale(1 .82)"/></svg>
EOF
IM="$(command -v magick || command -v convert || true)"
if [ -n "$IM" ]; then "$IM" -background none /tmp/dark-violet-fav.svg -define icon:auto-resize=48,32,16 "$SRC/static/img/favicon.ico" || true
else echo "(ImageMagick not found: favicon skipped, Horizon keeps its default icon)"; fi
chmod -R a+rX "$SRC"

# ---- register with Kolla ----
say "Registering theme"
strip_blocks; touch "$CS"
cp -n "$CS" "$CS.darkviolet.bak" 2>/dev/null || true
printf '%s\n' "# >>> DARKVIOLET" "SELECTABLE_THEMES = [('$THEME', '$LABEL', '$THEME_DIR')]" "DEFAULT_THEME = '$THEME'" "# <<< DARKVIOLET" >> "$CS"
if grep -q '^horizon_custom_themes' "$GLOBALS" 2>/dev/null; then
  echo "NOTE: $GLOBALS already has horizon_custom_themes. Add this entry under it by hand:"
  echo "  - name: $THEME"; echo "    label: $LABEL"
else
  printf '%s\n' "# >>> DARKVIOLET" "horizon_custom_themes:" "  - name: $THEME" "    label: $LABEL" "# <<< DARKVIOLET" >> "$GLOBALS"
fi

# ---- deploy ----
if reconfigure; then :; else
  say "kolla-ansible/inventory not found: installing live into the running container (re-run after any reconfigure/upgrade)"
  C="${HORIZON_CONTAINER:-$(docker ps --format '{{.Names}}' | grep -x horizon || true)}"
  [ -n "$C" ] || { echo "No horizon container found. Set INVENTORY=... or HORIZON_CONTAINER=..."; exit 1; }
  docker exec -u root "$C" mkdir -p /etc/openstack-dashboard/themes
  docker exec -u root "$C" rm -rf "$THEME_DIR"
  docker cp "$SRC" "$C:/etc/openstack-dashboard/themes/"
  docker exec -i -u root "$C" bash -c 'cat > /etc/openstack-dashboard/local_settings.d/_9999_darkviolet.py' <<PYEOF
AVAILABLE_THEMES = [('default', 'Default', 'themes/default'), ('$THEME', '$LABEL', '$THEME_DIR')]
SELECTABLE_THEMES = [('$THEME', '$LABEL', '$THEME_DIR')]
DEFAULT_THEME = '$THEME'
PYEOF
  docker exec -u root "$C" bash -c 'chmod -R a+rX /etc/openstack-dashboard/themes; export DJANGO_SETTINGS_MODULE=openstack_dashboard.settings; P=/var/lib/kolla/venv/bin; $P/python $P/manage.py collectstatic --noinput -v0 && $P/python $P/manage.py compress --force -v0'
  docker restart "$C"
fi
say "Done. Wait ~30s, then Ctrl+Shift+R in the browser."
