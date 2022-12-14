aws configure set {{ item.key }} {{ item.value }} --profile {{ aws_profile }}
