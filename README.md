# AI E-Commerce Platform

A self-hosted e-commerce & dropshipping platform for EU and US merchants — and a
network: shops running it can **supply each other** at wholesale.

**This repository is the release channel.** Published versions, the update
manifest, and the supplier-directory pointer live here. The application source is
maintained privately; what you install is the built bundle attached to a
[Release](../../releases).

> ⚠️ **No release published yet.** The first bundle will appear under
> [Releases](../../releases). The install steps below are ready for it.

---

## Contents

- [What you get](#what-you-get)
- [Requirements](#requirements)
- [Install](#install)
- [Staying up to date](#staying-up-to-date)
- [Joining the supplier network](#joining-the-supplier-network)
- [Support](#support)

---

## What you get

### Selling

| | |
|---|---|
| **Storefront** | Catalog, cart, checkout via **Stripe** and **PayPal**. Guest checkout, order tracking, support tickets, store credit. |
| **Payment model** | Authorize-then-capture on both rails — your customer is charged only *after* a supplier accepts the order. |
| **Taxes** | EU VAT-inclusive decomposition (store-wide or per-category, proportional shipping VAT) **and** US sales tax added on top, per registered state, destination-based. |
| **Currency** | Sell in EUR, USD, GBP, CHF, SEK, NOK, DKK, PLN, CZK, RON or BGN. Orders you have already taken keep the currency they were placed in and are never re-valued, and the shop refuses to switch while a customer still holds credit or a partner balance is unsettled. Prices are written the way your shop's language writes them. |
| **Shipping** | Destination zones with per-zone rates and free-over thresholds. Optionally those zones become the countries you ship to *at all* — checkout refuses the rest before taking money. Tracking numbers become clickable carrier links. |
| **Digital products** | Watermarked PDF delivery behind signed, download-limited links. |
| **CMS & theming** | Blog, pages, media library, switchable storefront themes. |

### Sourcing

| | |
|---|---|
| **Dropshipping** | Printful, Printify, CJdropshipping, AliExpress, generic REST, or your own inventory. Product import and supplier webhooks. |
| **Multi-supplier orders** | If one supplier fails, the order does not collapse: the others still ship and are charged, and the failed part is never billed. |
| **Price & stock sync** | Keeps the catalog aligned with your suppliers, with an optional guard that holds an order for review if a supplier's cost jumped beyond your tolerance, rather than fulfilling it at a loss. |

### Running the shop

| | |
|---|---|
| **Dashboard** | Any date range: revenue, orders, shipping, cost of goods, refunds (card vs store credit), gross profit and tax — each against the preceding period. Cost is recorded per line **at order time**, so a supplier repricing later cannot rewrite last quarter's margin. |
| **Accounting exports** | Give your bookkeeper a file, not a spreadsheet. **DATEV** (`Buchungsstapel`, SKR03 or SKR04, one posting per order split per tax rate) and **Xero** (sales invoices, plus a second credit-note file when the period contains refunds). Both cover the period shown on the dashboard, and both **stop rather than guess** — a tax rate you have not mapped to an account, a range crossing a year end, or a period holding two currencies produces an explanation instead of a file that looks correct. |
| **Returns & refunds** | Return-before-refund RMA flow, per-line restock rules, refunds in kind for store-credit orders. |
| **Admin** | Orders, products & variants, customers & store credit, categories, tickets, email templates, and settings for payments, taxes, shipping, returns, automation and sync. Every list filters straight from its column headers — pick values, type to search, sort — and the orders CSV export shows exactly the columns the list shows. |
| **System map** | A live diagram of your whole shop under Settings: every feature as a node with an on/off light, a live fact ("3 suppliers connected", "test keys"), and a click-through to the screen that controls it. Prints to PDF. |
| **Updates** | An in-dashboard banner when a new version is published here, and one-click install — on a schedule you choose, and unattended if you opt in. See [below](#staying-up-to-date). |

---

## Requirements

- **Node.js 18.18+** (20 recommended) — most shared hosts offer this under
  "Setup Node.js App"
- **MySQL 8 or MariaDB**
- HTTPS on your domain

## Install

Two ways. Pick by whether you have SSH access to your server.

### Method 1 — One command (SSH / VPS)

```sh
curl -fsSL https://raw.githubusercontent.com/kenanghasi-hash/ai-ecommerce-platform-public/main/install.sh | sh
```

Downloads the latest release, **verifies its checksum**, and unpacks it into
`./ai-shop`. Then:

```sh
cd ai-shop && PORT=3000 node server.js
```

…and open `https://your-domain.com/install`.

<details>
<summary>Options</summary>

```sh
sh install.sh --dir /var/www/shop     # install somewhere specific
sh install.sh --update --dir ...      # upgrade in place (keeps .env, uploads, storage)
sh install.sh --version v1.2.0        # pin a specific version
sh install.sh --manifest <url>        # install from a different release channel
```

The script refuses to overwrite an existing install unless you pass `--update`,
refuses to install at all if the checksum does not match, and leaves nothing
behind when it refuses. Prefer to read it first? It is
[right here](./install.sh) — download it, read it, then run it.

</details>

### Method 2 — Upload (shared hosting, cPanel/Plesk, no SSH)

**1. Download** `deploy.tar.gz` from the latest [Release](../../releases) and
unpack it on your computer.

**2. Upload** the contents to your app folder, by FTP or your hosting panel's
file manager.

**3. Register it as an application.** A shop is a program that must keep running,
not static files to serve. In your panel open **"Node.js" / "Setup Node.js App"**,
point it at the uploaded folder, set the startup file to `server.js`, pick
Node 18+, and start it.

**4. Open `https://your-domain.com/install`.**

### Either way: the wizard finishes the job

It asks for your shop address, your MySQL details and your admin account, then
creates the database tables, generates every secret, restarts once, and drops you
into the dashboard. It locks itself afterwards.

**There is nothing to configure by hand.** No environment file to write, no keys
to paste, no update URL to set — a fresh shop is already connected to the release
channel and the supplier directory. Payments, email, products, theme, taxes and
shipping are all point-and-click in the admin.

> **Docker instead?** The bundle also runs as a container alongside MySQL. See the
> deployment notes included in the release.

### Keep a backup

Your data lives in the database plus `public/uploads/` and `storage/`. Back up
both before any update. Updates preserve them, but a backup is what makes an
update reversible.

---

## Staying up to date

**Nothing to set up.** Every build follows this release channel out of the box, so
your shop checks daily — or as often as you like — and shows a banner in the admin
when a new version or a security advisory applies. The running version is in the admin sidebar, and the
time of the last check is on **Admin → Update** — so "nothing new" and "hasn't
looked" never get confused for each other.

The same channel also tells your shop where the **supplier directory** lives, so
that needs no configuration either. It keeps working if the directory moves, and
it keeps working if the channel itself has a bad day: your shop remembers the last
directory it was told about, across restarts, and only a manifest it could
actually read is allowed to change that.

### Applying an update

From **Admin → Update**, click **Download & install**. The shop fetches the
release, verifies its `sha256` checksum, swaps the application files while keeping
your `.env`, uploads and storage, restarts, and applies any database migrations.

Two things are deliberately true of this:

- **Nothing installs unattended unless you ask for it.** Out of the box you are
  told an update exists and you choose when. Unattended installs are available,
  but as a switch you turn on — see below.
- **Only the checksum-verified bundle from this channel can be installed.** There
  is no upload-your-own-code path, so a compromised admin account cannot be used
  to install foreign code.

Prefer the command line? `sh install.sh --update --dir <your-folder>` does the same
thing, preserving your `.env`, uploads and storage. Or upload the new bundle over
the old files by hand and finish the database step at **Admin → Update**.

### Deciding how updates reach you

**Admin → Update** has three controls. Between them they decide *when* your shop
looks and whether it acts on what it finds — never *where* it looks. Which channel
a shop follows is fixed in the build on purpose: it is exactly the setting someone
who got into your admin would want to repoint at their own code.

| Control | What it does |
|---|---|
| **Check now** | Looks immediately rather than waiting for the next scheduled check, ignoring anything already cached — so it tells you the truth the moment a release is published, instead of repeating what it knew an hour ago. |
| **Check automatically** | Hourly, every 6 hours, daily (the default), or weekly. A change takes effect at once. Below an hour would only hammer the channel; above a week, a security advisory could sit unseen longer than most incidents last. |
| **Install updates automatically** | **Off by default.** Turn it on and your shop installs new releases itself instead of waiting for the click. It grants nothing extra — same channel, same checksum, same bundle the button installs; it only removes the click. What it does do is restart your shop at a moment you did not choose, which is why it is a decision to make rather than inherit. The outcome of the last automatic install appears on the same page, so a failure is visible without reading server logs. |

If you turn automatic installs on, make sure the backups described under
[Keep a backup](#keep-a-backup) are actually happening — an update you did not
schedule is one you are not standing in front of.

<details>
<summary>Running your own release channel, or turning updates off</summary>

Set `UPDATE_MANIFEST_URL` in your `.env` to point at a different manifest — useful
if you run an independent network of shops. Set it to an empty string
(`UPDATE_MANIFEST_URL=""`) to switch update checks off entirely; your shop then
never contacts the channel, and you take responsibility for applying security
releases yourself.

That opt-out outranks everything, including **Check now** — the button will tell
you checks are switched off rather than quietly contacting the channel anyway.
"Never contact the channel" has to mean never.

</details>

---

## Joining the supplier network

Shops running this platform can sell their **own stock** to each other at
wholesale prices. It is off by default.

1. **Enable it** — Admin → Settings → Reseller program.
2. **Find suppliers** — Admin → Suppliers → *Peer suppliers* lists shops in the
   directory, each showing the currency it trades in and its payment terms —
   card on file, or on account — before you send a request.
   Send a connection request; once they approve, credentials are exchanged
   automatically and their catalog becomes importable like any other supplier.
3. **Or supply others** — tick *"List my shop in the supplier directory"*. Your
   listing is reviewed before it becomes visible.

Three things worth knowing:

- **The directory only lists.** Connections, orders, and money always run directly
  between the two shops. Nothing routes through the directory operator.
- **You approve every connection.** A shop finding you in the directory cannot
  order from you until you accept it.
- **A supplier in another currency is fine, and stays labelled.** Its costs are
  kept in the currency it quoted — never converted behind your back — so when you
  import, you set the retail price yourself instead of the shop inventing one from
  a rate. The same applies to Printful, Printify, CJdropshipping and AliExpress,
  which all quote in USD.
- **Card terms protect both sides.** A supplier that charges by card on file
  keeps your imported items off your storefront until your card is actually
  saved with them — so a customer can never buy something you cannot source.
  Extending "on account" terms is a per-shop decision behind an explicit
  warning, and every change of terms is recorded on the ledger.

Peer orders settle by **card on file** (saved once through a secure Stripe setup
page and charged as each order confirms) or on an invoiced ledger, whichever the
supplying shop offers.

### If a supplier seems to disappear

If a supplier shop changes its domain, your existing connection keeps pointing at
the old address and its orders will fail. Your shop detects this and emails you
that the shop now appears at a new address — but it **never switches over on its
own**, because a directory listing must not be able to redirect your orders or
payments. Confirm with the supplier, then reconnect.

---

## Support

- **Update problems** — Admin → Update shows the current and available version.
- **Payment setup** — Admin → Payments has a **Test connection** button that
  checks credentials, webhook registration and API version drift for both Stripe
  and PayPal.
- **Health** — `https://your-domain.com/api/health` reports configuration
  warnings, scheduler status and integration state. Useful to check first.

Issues and questions: [open an issue](../../issues).
