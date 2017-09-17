data test;
	a='abc defg';;
	b=prxchange('s/(\be|e|f|ef\b)/z/', -1, a);
	put b=;
run;
