# aws-wp-cookbooks
Chef cookbooks for AWS Bedrock Wordpress deploy with OpsWorks

How to use
----------

1. In AWS select OpsWorks

2. Select your stack

3. Select your layer

4. Go to Recipes -> Edit


Recipes and lifecycle events
----------------------------

* **Setup:** wordpress::setup

* **Deploy:** wordpress::deploy


Required Environment Variables
------------------------------

Before running the recipes you need to have the next environment variables set. You can define them in the Apps settings in OpsWorks.

* WP_ENV
* WP_HOME
* WP_SITEURL
* AUTH_KEY
* SECURE_AUTH_KEY
* LOGGED_IN_KEY
* NONCE_KEY
* AUTH_SALT
* SECURE_AUTH_SALT
* LOGGED_IN_SALT
* NONCE_SALT
* THEME_NAME
