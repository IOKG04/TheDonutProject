i,j,k,x,y,o,N;
#define R(t,x,y) f=x; \
		 x-=t*y; \
                 y+=t*f; \
                 f=(3-x*x-y*y)/2; \
                 x*=f; \
                 y*=f;
main(){
    float z[440],a=0,e=1,c=1,d=0,f,g,h,G,H,A,t,D;
    char b[440];
    for(;;){
	memset(b,32,440);
	g=0;
	h=1;
	memset(z,0,1760);
	for(j=0;j<90;j++){
	    G=0;
	    H=1;
	    for(i=0;i<314;i++){
		A=h+2;
		D=1/(G*A*a+g*e+5);
		t=G*A*e-g*a;
		x=20+15*D*(H*A*d-t*c);
		y=6+7*D*(H*A*c+t*d);
		o=x+40*y;
		N=8*((g*a-G*h*e)*d-G*h*a-g*e-H*h*c);
		if(11>y&&y>-1&&x>0&&40>x&&D>z[o]){
		    z[o]=D;
		    b[o]=(N>0?N:0)[".,-~:;=!*#$@"];
		}
		R(.04,H,G);
	    }
	    R(.14,h,g);
	}
	for(k=0;441>k;k++) putchar(k%40?b[k]:10);
	R(.04,e,a);
	R(.02,d,c);
	usleep(15000);
	printf('\n'+(" donut.c! \x1b[23A"));
    }
}

