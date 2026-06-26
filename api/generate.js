export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*')
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS')
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type')

    if (req.method === 'OPTIONS') return res.status(200).end()
    if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' })

    const { key, expires_at } = req.body
    if (!key) return res.status(400).json({ error: 'Missing key' })

    const SUPABASE_URL = process.env.SUPABASE_URL
    const SUPABASE_KEY = process.env.SUPABASE_KEY

    try {
        const response = await fetch(`${SUPABASE_URL}/rest/v1/keys`, {
            method: 'POST',
            headers: {
                'apikey': SUPABASE_KEY,
                'Authorization': `Bearer ${SUPABASE_KEY}`,
                'Content-Type': 'application/json',
                'Prefer': 'return=minimal'
            },
            body: JSON.stringify({
                key: key,
                expires_at: expires_at,
                is_used: false,
                hwid: null
            })
        })

        if (response.ok) {
            return res.status(200).json({ success: true })
        } else {
            const err = await response.text()
            console.error('Supabase error:', err)
            return res.status(500).json({ success: false, error: err })
        }
    } catch (e) {
        console.error('Catch error:', e)
        return res.status(500).json({ success: false, error: e.message })
    }
}
