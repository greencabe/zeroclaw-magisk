from pathlib import Path

path = Path('crates/zeroclaw-channels/src/orchestrator/mod.rs')
s = path.read_text()
old = '''    if !updated.channels.telegram.contains_key("default") {
        anyhow::bail!(
            "Telegram channel is not configured. Run \\
             `zeroclaw config set channels.telegram.<alias>.bot-token=<token>` \\
             (see docs/book/src/channels/overview.md for the full field list)."
        );
    }
'''
new = '''    let telegram_alias = updated
        .channels
        .telegram
        .iter()
        .find_map(|(alias, channel)| channel.enabled.then_some(alias.clone()))
        .or_else(|| updated.channels.telegram.keys().next().cloned());
    let Some(telegram_alias) = telegram_alias else {
        anyhow::bail!(
            "Telegram channel is not configured. Run \\
             `zeroclaw config set channels.telegram.<alias>.bot-token=<token>` \\
             (see docs/book/src/channels/overview.md for the full field list)."
        );
    };
'''
if old not in s:
    raise SystemExit('bind telegram config guard anchor not found')
s = s.replace(old, new, 1)
s = s.replace('''    // Locate (or create) the peer group bound to telegram.default. The
''', '''    // Locate (or create) the peer group bound to the configured Telegram alias. The
''', 1)
s = s.replace('''    let group_name = "telegram_default".to_string();
''', '''    let group_name = format!("telegram_{}", telegram_alias.as_str().replace('.', "_"));
''', 1)
s = s.replace('''            channel: "telegram.default".into(),
''', '''            channel: format!("telegram.{telegram_alias}").into(),
''', 1)
path.write_text(s)
