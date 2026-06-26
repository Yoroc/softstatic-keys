export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*')
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS')
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type')

    if (req.method === 'OPTIONS') return res.status(200).end()
    if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' })

    const { key, hwid } = req.body
    if (!key || !hwid) return res.status(400).json({ valid: false, error: 'Missing key or hwid' })

    const SUPABASE_URL = process.env.SUPABASE_URL
    const SUPABASE_KEY = process.env.SUPABASE_KEY

    try {
        // Fetch key from Supabase
        const response = await fetch(`${SUPABASE_URL}/rest/v1/keys?key=eq.${key}&select=*`, {
            headers: {
                'apikey': SUPABASE_KEY,
                'Authorization': `Bearer ${SUPABASE_KEY}`,
                'Content-Type': 'application/json',
            }
        })

        const data = await response.json()

        if (!data || data.length === 0) {
            return res.status(200).json({ valid: false, error: 'Invalid key' })
        }

        const entry = data[0]

        // Check HWID lock
        if (entry.hwid && entry.hwid !== '' && entry.hwid !== hwid) {
            return res.status(200).json({ valid: false, error: 'Key locked to another device' })
        }

        // Check expiry
        if (entry.expires_at) {
            const expiry = new Date(entry.expires_at)
            const now = new Date()
            if (now > expiry) {
                return res.status(200).json({ valid: false, error: 'Key expired' })
            }
        }

        // First time use — lock to device
        if (!entry.is_used || !entry.hwid || entry.hwid === '') {
            await fetch(`${SUPABASE_URL}/rest/v1/keys?key=eq.${key}`, {
                method: 'PATCH',
                headers: {
                    'apikey': SUPABASE_KEY,
                    'Authorization': `Bearer ${SUPABASE_KEY}`,
                    'Content-Type': 'application/json',
                    'Prefer': 'return=minimal',
                },
                body: JSON.stringify({
                    hwid: hwid,
                    is_used: true,
                })
            })
        }

        return res.status(200).json({ valid: true })

    } catch (e) {
        return res.status(500).json({ valid: false, error: 'Server error' })
    }
}
