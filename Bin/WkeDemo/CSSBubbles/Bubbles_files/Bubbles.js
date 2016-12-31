/**
 * JavaScript Bubbles
 *  By EtherDream 2010
 */
+function()
{
	//
	// 浏览器辅助
	//
	var _VER_ = navigator.userAgent;
	var _IE6_ = /IE 6/.test(_VER_);

	var STD = !!window.addEventListener;
	var de = document.documentElement;

	_IE6_ && document.execCommand("BackgroundImageCache", false, true);


	//
	// 常量
	//
	var D = 222;				//泡泡直径
	var K = 0.999;

	var POW_RATE = 0.0001;		//补偿概率
	var POW_RANGE = 0.8;		//补偿范围(基于诞生速度)

	function SPEED_X(){return 8 + RND() * 4}
	function SPEED_Y(){return 6 + RND() * 2}


	var arrBubs = [];
	var iBottom;
	var iRight;


	var SQRT = Math.sqrt;
	var ATAN2 = Math.atan2;
	var SIN = Math.sin;
	var COS = Math.cos;
	var ABS = Math.abs;
	var RND = Math.random;
	var ROUND = Math.round;


	function Timer(call, time)
	{
		var last = +new Date;
		var delay = 0;

		return setInterval(function()
		{
			// 时间差累计
			var cur = +new Date;
			delay += (cur - last);
			last = cur;

			// 计算帧数
			if(delay >= time)
			{
				call();
				delay %= time;
			}
		}, 1);
	}

	Timer(update, 17);

	CreateBubble = function()
	{
		var bub = new Bubble();

		bub.setX(0);
		bub.setY(0);
		bub.vx = SPEED_X();
		bub.vy = SPEED_Y();

		arrBubs.push(bub);
	};



	function update()
	{
		var n = arrBubs.length;
		var bub, bub2;
		var i, j;


		updateWall();

		for(i=0; i<n; i++)
		{
			bub = arrBubs[i];

			bub.paint();

			bub.vx *= K;
			bub.vy *= K;

			if(RND() < POW_RATE)
			{
				bub.vx = SPEED_X() * (1 + RND() * POW_RANGE);
				bub.vy = SPEED_Y() * (1 + RND() * POW_RANGE);
			}

			bub.setX(bub.x + bub.vx);
			bub.setY(bub.y + bub.vy);
			checkWalls(bub);
		}

		for(i=0; i<n-1; i++)
		{
			bub = arrBubs[i];

			for(j=i+1; j<n; j++)
			{
				bub2 = arrBubs[j];
				checkCollision(bub, bub2);
			}
		}
	}

	function updateWall()
	{
		iRight = de.clientWidth - D;
		iBottom = de.clientHeight - D;
	}

	function checkWalls(bub)
	{
		if(bub.x < 0)
		{
			bub.setX(0);
			bub.vx *= -1;
		}
		else if(bub.x > iRight)
		{
			bub.setX(iRight);
			bub.vx *= -1;
		}

		if(bub.y < 0)
		{
			bub.setY(0);
			bub.vy *= -1;
		}
		else if(bub.y > iBottom)
		{
			bub.setY(iBottom);
			bub.vy *= -1;
		}
	}

	function rotate(x, y, sin, cos, reverse)
	{
		if(reverse)
			return {x: x * cos + y * sin, y: y * cos - x * sin};
		else
			return {x: x * cos - y * sin, y: y * cos + x * sin};
	}

	function checkCollision(bub0, bub1)
	{
		var dx = bub1.x - bub0.x;
		var dy = bub1.y - bub0.y;
		var dist = SQRT(dx*dx + dy*dy);
	
		if(dist < D)
		{
			// 计算角度和正余弦值
			var angle = ATAN2(dy,dx);
			var sin = SIN(angle);
			var cos = COS(angle);

			// 旋转 bub0 的位置
			var pos0 = {x:0, y:0};

			// 旋转 bub1 的速度
			var pos1 = rotate(dx, dy, sin, cos, true);

			// 旋转 bub0 的速度
			var vel0 = rotate(bub0.vx, bub0.vy, sin, cos, true);

			// 旋转 bub1 的速度
			var vel1 = rotate(bub1.vx, bub1.vy, sin, cos, true);

			// 碰撞的作用力
			var vxTotal = vel0.x - vel1.x;
			vel0.x = vel1.x;
			vel1.x = vxTotal + vel0.x;

			// 更新位置
			var absV = ABS(vel0.x) + ABS(vel1.x);
			var overlap = D - ABS(pos0.x - pos1.x);

			pos0.x += vel0.x / absV * overlap;
			pos1.x += vel1.x / absV * overlap;

			// 将位置旋转回来
			var pos0F = rotate(pos0.x, pos0.y, sin, cos, false);
			var pos1F = rotate(pos1.x, pos1.y, sin, cos, false);

			// 将位置调整为屏幕的实际位置
			bub1.setX(bub0.x + pos1F.x);
			bub1.setY(bub0.y + pos1F.y);
			bub0.setX(bub0.x + pos0F.x);
			bub0.setY(bub0.y + pos0F.y);

			// 将速度旋转回来
			var vel0F = rotate(vel0.x, vel0.y, sin, cos, false);
			var vel1F = rotate(vel1.x, vel1.y, sin, cos, false);

			bub0.vx = vel0F.x;
			bub0.vy = vel0F.y;
			bub1.vx = vel1F.x;
			bub1.vy = vel1F.y;
		}
	}



	var APLHA = 0.8;
	var POW = [1, APLHA, APLHA*APLHA];

	/******************************
	 * Class Bubble
	 ******************************/
	function Bubble()
	{
		var kOpa = [], kStp = [];
		var arrFlt = [];
		var oBox = document.body.appendChild(document.createElement("div"));


		styBox = oBox.style;
		styBox.position = "absolute";
		styBox.width = D + "px";
		styBox.height = D + "px";

		for(var i=0; i<4; i++)
		{
			var div = document.createElement("div");
			var sty = div.style;

			sty.position = "absolute";
			sty.width = "222px";
			sty.height = "222px";

			oBox.appendChild(div);

			// 泡泡顶层
			if(i == 3)
			{
				if(_IE6_)
					sty.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src=heart.png)";
				else
					sty.backgroundImage = "url(./Bubbles_files/heart.png)";
				break;
			}

			kOpa[i] = 3 * RND();
			kStp[i] = 0.02 * RND();

			if(STD)
			{
				sty.backgroundImage = "url(./Bubbles_files/ch" + i + ".png)";
				arrFlt[i] = sty;
			}
			else
			{
				sty.filter = "alpha progid:DXImageTransform.Microsoft.AlphaImageLoader(src=ch" + i + ".png)";
				arrFlt[i] = div.filters.alpha;
			}
		}

		this.styBox = styBox;
		this.kOpa = kOpa;
		this.kStp = kStp;
		this.arrFlt = arrFlt;
	}

	Bubble.prototype.setX = function(x)
	{
		this.x = x;
		this.styBox.left = ROUND(x) + "px";
	};

	Bubble.prototype.setY = function(y)
	{
		this.y = y;
		this.styBox.top = ROUND(y) + "px";
	};

	Bubble.prototype.paint = function()
	{
		var i, v;

		for(i=0; i<3; i++)
		{
			v = ABS(SIN(this.kOpa[i] += this.kStp[i] * RND()));
			v *= POW[i];

			v = ((v * 1e4) >> 0) / 1e4;
			this.arrFlt[i].opacity = STD? v : v*100;
		}
	};

}();