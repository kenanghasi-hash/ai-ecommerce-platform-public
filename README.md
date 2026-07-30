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
| **Returns & refunds** | Return-before-refund RMA flow, per-line restock rules, refunds in kind for store-credit orders. |
| **Admin** | Orders, products & variants, customers & store credit, categories, tickets, email templates, and settings for payments, taxes, shipping, returns, automation and sync. |
| **Updates** | An in-dashboard banner when a new version is published here, and one-click install — see [below](#staying-up-to-date). |

---

## Requirements

- **Node.js 18.18+** (20 recommended) — most shared hosts offer this under
  "Setup Node.js App"
- **MySQL 8 or MariaDB**
- HTTPS on your domain

## Install

You don't clone this repository. You deploy the **release bundle**: one
self-contained folder with everything the server needs.

**1. Download** `deploy.tar.gz` from the latest [Release](../../releases) and
unpack it.

**2. Upload** the contents to your app folder on the server, by FTP or your
hosting panel's file manager.

**3. Register it as an application.** A shop is a program that must keep running,
not static files to serve. In your hosting panel open **"Node.js" / "Setup Node.js
App"**, point it at the uploaded folder, set the startup file to `server.js`, pick
Node 18+, and start it.

No environment variables are needed — a fresh shop boots into setup mode.

**4. Open `https://your-domain.com/install`.** The wizard asks for your shop
address, your MySQL details and your admin account. It creates the database
tables, generates every secret, restarts once, and drops you into the dashboard.
It then locks itself.

**5. Configure** payments, email, products or suppliers, theme, taxes and
shipping — all from the admin.

> **Docker instead?** The bundle also runs as a container alongside MySQL. See the
> deployment notes included in the release.

### Keep a backup

Your data lives in the database plus `public/uploads/` and `storage/`. Back up
both before any update. Updates preserve them, but a backup is what makes an
update reversible.

---

## Staying up to date

Add **one line** to your shop's `.env`:

```bash
UPDATE_MANIFEST_URL="https://github.com/kenanghasi-hash/ai-ecommerce-platform-public/releases/latest/download/manifest.json"
```

That single line does two jobs:

1. **Update notifications** — your shop checks daily and shows a banner in the
   admin dashboard when a newer version or a security advisory applies.
2. **Supplier directory** — it also carries the address of the supplier directory,
   so you never have to configure that separately, and it keeps working if the
   directory ever moves.

### Applying an update

From **Admin → Update**, click **Download & install**. The shop fetches the
release, verifies its `sha256` checksum, swaps the application files while keeping
your `.env`, uploads and storage, restarts, and applies any database migrations.

Two things are deliberately true of this:

- **Nothing installs unattended.** You are told an update exists; you decide when.
- **Only the checksum-verified bundle from this channel can be installed.** There
  is no upload-your-own-code path, so a compromised admin account cannot be used
  to install foreign code.

Prefer doing it by hand? Upload the new bundle over the old files (keep
`public/uploads/`), restart, then finish the database step at **Admin → Update**.

---

## Joining the supplier network

Shops running this platform can sell their **own stock** to each other at
wholesale prices. It is off by default.

1. **Enable it** — Admin → Settings → Reseller program.
2. **Find suppliers** — Admin → Suppliers → *Peer suppliers* lists shops in the
   directory. Send a connection request; once they approve, credentials are
   exchanged automatically and their catalog becomes importable like any other
   supplier.
3. **Or supply others** — tick *"List my shop in the supplier directory"*. Your
   listing is reviewed before it becomes visible.

Two things worth knowing:

- **The directory only lists.** Connections, orders, and money always run directly
  between the two shops. Nothing routes through the directory operator.
- **You approve every connection.** A shop finding you in the directory cannot
  order from you until you accept it.

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
