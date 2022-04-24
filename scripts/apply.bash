source ../secrets/token.env

terraform apply -var "do_token=${DO_API_TOKEN}" -var "pvt_key=`realpath ../secrets/ssh/tf`" -var "pub_key=`realpath ../secrets/ssh/tf.pub`"
