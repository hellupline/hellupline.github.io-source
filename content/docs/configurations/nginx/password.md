---
title: 'password'

---

{{< code file="/files/docs/configurations/nginx/password.conf" language="nginx" download="true" >}}

```bash
# generate your passwod  # htpasswd -c ./server.htpasswd -B username
perl -le '
    my $commentary = "testing";
    my $username = "username";
    my $password = crypt("your-password", "salt-hash");
    my $row = "$username:$password:$commentary";
    open(my $fh, ">>", "server.htpasswd") or die;
    say $fh $row;
    close $fh;
    print $row;
'
docker run --detach --name nginx-password \
    --volume "${PWD}/password.conf:/etc/nginx/conf.d/default.conf" \
    --volume "${PWD}/server.htpasswd:/etc/nginx/server.htpasswd" \
    --publish "8080:80" \
    --workdir "/usr/share/nginx/html/" \
    nginx
curl -SsD- -u 'username:your-password' http://localhost:8080/
curl -SsD- http://localhost:8080/
curl -SsD- http://localhost:8080/public
docker stop nginx-password
docker rm nginx-password
```
