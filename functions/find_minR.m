function dmin= find_minR(a,b,c,d,m)

dd(1)=sqrt(dot(cross(m-a,a-b),cross(m-a,a-b)))/sqrt(dot(a-b,a-b));
dd(2)=sqrt(dot(cross(m-b,b-c),cross(m-b,b-c)))/sqrt(dot(b-c,b-c));
dd(3)=sqrt(dot(cross(m-c,c-d),cross(m-c,c-d)))/sqrt(dot(c-d,c-d));
dd(4)=sqrt(dot(cross(m-d,d-a),cross(m-d,d-a)))/sqrt(dot(d-a,d-a));

dmin=min(dd);