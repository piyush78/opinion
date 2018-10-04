require 'aws-sdk'
Aws.config.update ({
region: 'us-west-2',
:access_key_id => 'XXXXXXXXX',
:secret_access_key => 'XXXXXXXXX'
})

# cognitoidentity = Aws::CognitoIdentity::Client.new(region: 'us-west-2')
# cognitoidentity.myapp
