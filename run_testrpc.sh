# create three accounts with 1000 ETH each
testrpc --port 8550\
 --gasLimit=10000000\
 --account="0x83c14ddb845e629975e138a5c28ad5a72a49252ea65b3d3ec99810c82751cc3a,1000000000000000000000" --unlock "0xaec3ae5d2be00bfc91597d7a1b2c43818d84396a"\
 --account="0xd3b6b98613ce7bd4636c5c98cc17afb0403d690f9c2b646726e08334583de101,1000000000000000000000" --unlock "0xf1f42f995046e67b79dd5ebafd224ce964740da3"\
 --account="0x1283183f4e28da6d6e16b973a7fd81fa53874f0258ac702f9b0756b8cdd44c04,1000000000000000000000" --unlock "0x04411d87358baa12435da46b34e8d65f142bb47b"\
 --account="0x1283183f4e28da6d6e16b973a7fd81fa53874f0258ac702f9b0756b8cdd44c05,1000000000000000000000" --unlock "0x04411d87358baa12435da46b34e8d65f142bb48b" 
# 0xaec3ae5d2be00bfc91597d7a1b2c43818d84396a - chairman
# 0xf1f42f995046e67b79dd5ebafd224ce964740da3 - voter1
# 0x04411d87358baa12435da46b34e8d65f142bb47b - voter2
# 0x04411d87358baa12435da46b34e8d65f142bb48b - voter3
