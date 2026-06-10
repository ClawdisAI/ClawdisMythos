<p align="center">
  <img src="https://cdn.prod.website-files.com/69082c5061a39922df8ed3b6/6a2970ee5005ba5486967b66_clawdisbanner.png" alt="Clawdis" width="100%" />
</p>

<h1 align="center">Clawdis</h1>

<p align="center"><strong>Private rails for the agentic economy on Solana.</strong></p>

<p align="center">
  <em>In the old tongue, Clawdis was the keeper of unseen paths — the one who walked between.</em>
</p>

<p align="center">
  Stealth addresses and x402 payments for AI agents — every payment lands at a
  fresh, single-use address that only the recipient can spend, so who paid whom,
  and how much, never reaches the public ledger.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Site-Coming%20Soon-84D9B5?style=for-the-badge&logoColor=06231b" alt="Site Coming Soon" height="34" />
  &nbsp;
  <a href="https://x.com/ClawdisAI"><img src="https://img.shields.io/badge/%40ClawdisAI-000000?style=for-the-badge&logo=x&logoColor=white" alt="X / Twitter" height="34" /></a>
  &nbsp;
  <a href="https://github.com/ClawdisAI"><img src="https://img.shields.io/badge/ClawdisAI-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" height="34" /></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-84D9B5?style=flat-square" alt="MIT License" />
  <img src="https://img.shields.io/badge/Solana-mainnet-84D9B5?style=flat-square" alt="Solana mainnet" />
  <img src="https://img.shields.io/badge/x402-SVM-84D9B5?style=flat-square" alt="x402 SVM" />
  <img src="https://img.shields.io/badge/built%20with-TypeScript-9c958a?style=flat-square" alt="TypeScript" />
</p>

---

## The Myth

Before the ledger, there were paths that left no trace. Clawdis walked them — the god of unseen movement, patron of those who move between worlds without touching either. Where others cast long shadows across every transaction, Clawdis left nothing: no record, no trail, no proof of passage except the thing that arrived.

The ancients understood what modern markets forgot: *not every movement needs a witness.*

Clawdis is that principle, made executable.

---

## Overview

The agent economy is being built in public, on rails that publish every payment
forever. For an autonomous agent that transacts continuously, the public ledger
becomes a strategy leak: who it pays, how much, and when are all readable straight
from the transaction graph.

**Clawdis closes that gap at the address layer.** It combines two primitives:

- **Stealth addresses** — the recipient publishes one long-lived meta-address;
  senders derive a fresh, single-use destination for every payment that cannot be
  linked to one another or back to the recipient.
- **x402 payments** — the dormant HTTP `402 Payment Required` status code, turned
  into a working machine-to-machine settlement layer so one agent can pay another
  over plain HTTP, with the payment landing at a stealth address.

The result: agents keep operating on standard Solana — standard wallets, standard
SPL tokens — without surrendering their strategy to anyone with a block explorer.
An operator retains a **viewing key** for a complete, attributable audit trail, so
Clawdis is private from the public, not from you. It is confidentiality
infrastructure, not a mixer.

## Links

<p align="center">
  <img src="https://img.shields.io/badge/Site-Coming%20Soon-84D9B5?style=for-the-badge&logoColor=06231b" alt="Site Coming Soon" height="34" />
  &nbsp;
  <a href="https://x.com/ClawdisAI"><img src="https://img.shields.io/badge/%40ClawdisAI-000000?style=for-the-badge&logo=x&logoColor=white" alt="X / Twitter" height="36" /></a>
  &nbsp;
  <a href="https://github.com/ClawdisAI"><img src="https://img.shields.io/badge/ClawdisAI-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" height="36" /></a>
</p>

## Features

- **Single-use stealth addresses** — derived per payment on ed25519, no reuse, no clustering.
- **x402 stealth payments** — pay any agent endpoint over HTTP; settlement lands at a fresh address.
- **View-tag scanning** — one-byte view tags discard ~99.6% of announcements before any derivation.
- **Viewing keys** — selective disclosure: export a deterministic audit trail without revealing strategy.
- **Gasless sweeps** — SOL and SPL, fee-sponsored, so no SOL needs to be pre-funded at a destination.
- **Non-custodial** — spending keys are derived from your seed and never leave your process.
- **Three surfaces** — TypeScript SDK, MCP server, and a REST API. Same engine, same guarantees.

## Quickstart

```bash
npm install @clawdis/sdk
```

```ts
import { createClawdis } from "@clawdis/sdk";

const agent = createClawdis({ chain: "solana" });

const { receipt } = await agent.payX402({
  url: "https://api.vendor.xyz/infer",
  to: "clawdis:vendor-7",
  amount: 0.02,
  token: "USDC",
});

const incoming = await agent.scan(agent.viewingKey());
```

See [`examples/`](./examples) for runnable end-to-end flows.

## Packages

This is a monorepo for the Clawdis protocol and its agent-facing surfaces.

| Package | Description |
| --- | --- |
| [`@clawdis/sdk`](./packages/sdk) | TypeScript SDK — stealth derivation, x402 payments, scanning, sweeps. |
| [`@clawdis/mcp-server`](./packages/mcp-server) | Model Context Protocol server exposing Clawdis tools to Claude Code, Cursor, Windsurf, and any MCP host. |


<p align="center">
  <a href="https://bags.fm/2yDL2okKMtkxtSomVWVfr6Y8JDBuidRX3e4Qx8hBBAGS">
    <img src="https://img.shields.io/badge/buy%20%24CLAWDIS-84D9B5?style=for-the-badge&logo=solana&logoColor=06231b" alt="Buy on pump.fun" height="36" />
  </a>
</p>

<p align="center">
  <code>2yDL2okKMtkxtSomVWVfr6Y8JDBuidRX3e4Qx8hBBAGS</code>
</p>

## How it works

A minimal on-chain program announces payments; everything cryptographic happens
client-side, inside your agent.

1. **Invoke.** The recipient publishes a meta-address — `clawdis:spend.view`.
2. **Derive.** The sender combines an ephemeral keypair with the recipient's public keys to compute a unique stealth address, entirely client-side.
3. **Pay.** Funds are sent to the stealth address; the ephemeral public key and a one-byte view tag are emitted in an on-chain announcement.
4. **Scan.** The recipient filters announcements by view tag, recognizes payments meant for them with their viewing key, and derives the key to spend.

```
on-chain program  ->  pure-TS privacy engine  ->  SDK / MCP / REST
```

## Architecture

```
.
├── packages/
│   ├── sdk/            # @clawdis/sdk — client engine (derivation, x402, scan, sweep)
│   └── mcp-server/     # @clawdis/mcp-server — MCP tools for agent hosts
├── examples/           # runnable end-to-end flows
├── docs/               # protocol documentation
└── assets/             # brand assets
```

## Roadmap

- [x] Stealth scheme and on-chain announcement program on Solana mainnet
- [x] TypeScript SDK, MCP server, and REST surfaces
- [ ] Independent audit and sRFC submission for the stealth-address standard
- [ ] Confidential amounts (BN-254) and network-privacy relays
- [ ] Cross-SVM coverage

## Security

Clawdis is in active development; the stealth scheme and on-chain program are
scoped for third-party audit. Do not treat mainnet usage as audited until that
completes. To report a vulnerability, see [SECURITY.md](./SECURITY.md) — please do
not open public issues for security reports.

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md) for the
development workflow, and [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

## License

Released under the [MIT License](./LICENSE). © Clawdis.

---

<p align="center">
  <img src="https://cdn.prod.website-files.com/69082c5061a39922df8ed3b6/6a29738a781be9b01c228643_oJJkr4hP_400x400.jpg" alt="Clawdis" width="56" style="border-radius:50%" />
</p>

<p align="center"><sub>Built on Solana · <a href="https://www.prowl.finance/">clawdis.ai</a></sub></p>
