### SPF
SPF 记录是一种域名服务 (DNS) 记录，可确定允许哪些邮件服务器代表您的域来发送电子邮件。

SPF的设置选项可以参考：http://www.openspf.org/SPFRecordSyntax

- a：所有该域名的A记录都为通过，a不指定的情况下为当前域名
- ip4：指定通过的IP
- mx：mx记录域名的A记录IP可以发邮件
- all：结束标志，“-”表示只允许设置的记录为通过，“~”表示失败，通常用于测试，“+”表示忽略SPF

`v=spf1 a mx -all`，
则表示允许A记录和MX记录IP收发邮件。
添加的方法是在域名DNS解析设置一个txt记录，主机记录为空或者@，记录值为
`v=spf1 a mx -all`，其他可以忽略。

`v=spf1 include:spf.mail.qq.com include:yx.mail.qq.com ~all`
### DKIM
DomainKeys Identified Mail的缩写，域名密钥识别邮件标准。

> 初始化过程见 `entrypoint.sh`

`cat /etc/opendkim/keys/$MYHOST/default.txt`
添加到DNS，主机记录为default._domainkey，记录值为括号里面的（去掉引号）

### DMARC
DMARC协议是有效解决信头From伪造而诞生的一种新的邮件来源验证手段，为邮件发件人地址提供强大保护，并在邮件收发双方之间建立起一个数据反馈机制。

DMARC记录中常用的参数解释

- p：用于告知收件方，当检测到某邮件存在伪造我（发件人）的情况，收件方要做出什么处理，处理方式从轻到重依次为：none为不作任何处理；quarantine为将邮件标记为垃圾邮件；reject为拒绝该邮件。初期建议设置为none。
- rua：用于在收件方检测后，将一段时间的汇总报告，发送到哪个邮箱地址。
- ruf：用于当检测到伪造邮件时，收件方须将该伪造信息的报告发送到哪个邮箱地址。

`v=DMARC1;p=reject;rua=master@$MYHOST`
意思是拒绝伪造邮件，并且将一段时间的汇总报告发送给我。

添加TXT记录，主机名：_dmarc，记录值：v=DMARC1;p=reject;rua=master@$MYHOST

### PTR
PTR记录也就是IP反向解析，我们常见的解析都是将域名A记录解析到IP，PTR则是将IP反向解析到对应的域名，通过设置PTR可以提高发信方的信誉，从而提高到达率。

添加好了以后可以通过以下命令查看
```
dig -x  IP

```
