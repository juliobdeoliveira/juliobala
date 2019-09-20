Tier_Arr=$(echo $CliqrDependencies | tr "," "\n")
for tier  in $Tier_Arr
    do
       private_ip="CliqrTier_${tier}_IP"
	   public_ip="CliqrTier_${tier}_PUBLIC_IP"

		sed -i "s/${!private_ip}/${!public_ip}/g" /etc/haproxy/haproxy.cfg
	done

