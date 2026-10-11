x=[1+i 1-i -1+i -1-j].'/sqrt(2);
M=4;
x=exp(i*2*pi*(((0:M)+0.5)/M)).';

phi=0.3;
alpha=0.0;
g=1+alpha;

% Fettweis and B Lindoff and Fredrik N
K1=(1+g*exp(-i*phi))/sqrt(2*(1+g*g));
K2=(1-g*exp(i*phi))/sqrt(2*(1+g*g));
y=K1*x+K2*conj(x);

% Elias
a=cos(phi/2)+i*alpha*sin(phi/2);
b=alpha*cos(phi/2)-i*sin(phi/2);
z=a*x+b*conj(x);

% Andres
k=g;
kRe=sqrt(2/(1+k*k));
kIm=sqrt(2*k*k/(1+k*k));
w=kRe*(real(x)+sin(phi)*imag(x))+kIm*i*cos(phi)*imag(x);

% plotting
plot([x y z w],'*')
hold on
xx=linspace(0,2*pi);yy=cos(xx)+i*sin(xx);
plot(real(yy),imag(yy))
hold off
axis(1.5*[-1 1 -1 1])
xlabel('blue-orig, green-fettweis, red-elias, andres')
grid

q=[y z w];
disp('Gain in whole IQ imbalance block')
disp(sqrt(mean(abs(q).^2)))
disp('Gain')
disp(sqrt(mean(imag(q).^2)./mean(real(q).^2)))
disp('Phase')
mean(angle(q)-repmat(angle(x),1,3))
