#!/bin/bash
source /tmp/hf-venv/bin/activate
export HF_API_KEY="447bd4b3-7bf6-40c1-95e1-425ec6b72c84"
export HF_API_SECRET="89bb93ede817a5d999adf083736de68ffece546f167346ea51ec7fc957342930"
export HF_KEY="447bd4b3-7bf6-40c1-95e1-425ec6b72c84:89bb93ede817a5d999adf083736de68ffece546f167346ea51ec7fc957342930"

python3 << 'ENDPY'
import higgsfield_client

models = [
    "bytedance/seedream/v4/text-to-image",
    "higgsfield-ai/soul/standard",
    "seedream-5.0-lite",
    "reve/text-to-image",
    "flux/text-to-image",
    "soul/standard",
    "gpt-image-2",
    "seedream",
    "soul",
    "flux",
]
for m in models:
    try:
        r = higgsfield_client.subscribe(m, {"prompt": "brown sugar crystal macro photo", "resolution": "720p"})
        print("WORKS: " + m)
        print("Result: " + str(r))
        break
    except Exception as e:
        print(m + ": " + str(e)[:60])
ENDPY
