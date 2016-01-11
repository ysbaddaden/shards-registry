# Webhooks

By configuring webhooks on your repositories, you can have new versions of your
Shards to be detected automatically (and immediately) by the Shards Registry.

For now, only GitHub is supported.

## GitHub

All repositories are configured with exactly the same configuration.

1. Declare the `#PROTOCOL#:#HOSTNAME#/api/webhooks/github`;
2. Select the `application/json` content type;
3. Set your personnal API key as the secret
4. select the following individual events: `Create` and `Delete` and unselect
   all other events.
5. Activate the Webhook

Once the Webhook s created, you may verify that the `ping` event is correctly
delivered. It should have been delivered correctly.
