
## Chat Noir

Chat Noir是法语中黑猫的意思，我第一次玩到这个游戏是某编译器[附带的程序](http://docs.racket-lang.org/games/chat-noir.html)，后来有人在微信上发布了同样玩法的“围住神经猫”。你也可以[在线玩](http://www.silvergames.com/circle-the-cat)。

![game demo](http://sae-gif.qiniudn.com/chat_noir_demo.png) 


玩几局就能发现规律，猫每一步走的都是到达边界点的最短路径。如果编程实现这个游戏的话，就是寻径，地图可以抽象成无向连通图，每条路径权值相等，如果有n个节点，大概就会有3*n条边。可以用Dijkstra算法，但不划算，用bfs比较好。

## 具体实现

最近学了点Swift，正好拿来练手。

首先我们需要一个“地图”，需要一只猫，地图上每一点都有两种状态(有障碍物 or 无障碍物),我们还需要一组view来绘制地图上的点

```swift

/*
 * Point 的定义
 */
 
struct Point :Equatable,Hashable{
    var x: Int
    var y: Int
    var empty: Bool
    
    var hashValue :Int {
        get{
            
            return x << 6 + y
        }
    }
}

func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

var worldMap = Array< Array<Bool> >()
var views = Array< Array<UIView?> >()
var catPosition:Point = Point(x:0,y:0,empty:true)

let defaultColor = UIColor(red: 0.23, green: 0.78, blue: 0.33, alpha: 1)
let brickColor = UIColor(red: 0.11, green: 0.32, blue: 0.79, alpha: 1)
let catImageView = UIImageView(image: UIImage(named: "chatNoir"))

```

初始化方法中，我们需要给worldMap、views、等初始化，还需要给猫一个随机的地点，随机画几块障碍物，略过

view还得响应用户的Tap Gesture，略过

下面给猫想对策：

```swift
	// bfs 接受一个参数：猫の位置
	func bfs(startPoint:Point) -> Bool{
		/*
		*  如果猫触碰到了边界，gameOver，返回true是因为猫找到了出口，很开心
		*/
		if(reachBoundary(startPoint)){
			 gameOver()
			 return true
		 }
       
        let height = worldMap.count
        let width  = worldMap[0].count
        
		/*
		 * 初始化一个二维数组，记录访问过的位置
		 */
        var tmp = [Bool](count:width , repeatedValue: false)
        var visited = [Array<Bool>](count:height,repeatedValue: tmp)
        
		/*
		 * parent 是一个<Point,Point>的字典，记录路径。value是key的上一个节点
		 * queue是队列
	     */
        var parent = [Point:Point]() //
        var queue = Queue<Point>()
        
        queue.enQueue(startPoint)
        visited[startPoint.x][startPoint.y] = true
        
		/*
		 * bfs 的流程
		 */
        while (!queue.isEmpty()){
            var node = queue.deQueue()
            
            if(self.reachBoundary(node!)){
                var father = parent[node!]
                self.backtrace(parent, start: startPoint, end: node!)
                return true
            }
        
            var adjacent = getAdjacent(node!, visited: &visited)
            
            for someNode in adjacent{
                parent[someNode] = node!
                queue.enQueue(someNode)
            }
        }
		
		/*
		 * 返回false 是因为猫找不到出口，很难受
		 */
        return false
    }

```

其中getAdjacent是找临接点，太长不贴。backtrace就是回溯找到猫下一步走哪儿能最快找到出口。

```swift
	
	func backtrace(parent:[Point:Point],start:Point,end:Point) -> Point {
        var tmpPoint = end
        while(parent[tmpPoint] != start){
            tmpPoint = parent[tmpPoint]!
        }
		
        //cat move to tmpPoint
        catImageView.removeFromSuperview()
        catPosition = tmpPoint
        
        var aView = views[catPosition.x][catPosition.y]
        aView?.addSubview(catImageView)
        
        return tmpPoint
    }
	
```

截图如下,[github](https://github.com/RRanddom/ChatNoir)

![screenshot](http://sae-gif.qiniudn.com/game_screen_shot.png)

## 难题

初始化状态应该如何设置，使得猫可以被围住？这个问题有点复杂，很多山寨这个游戏的人都没有考虑到，先把问题放这儿。

## Swift怎么样

初体验，感受如下

* _pros_
	* 泛型、操作符重载使得代码量精简了很多
	* 语法糖很舒服，特别是数组和字典，写起来很爽
	* closure看起来不错，熟练掌握后，可以施展很多黑魔法

* _cons_
	* 没有STL之类的东西，很多数据结构和算法需要自己写，比如没有Queue、Stack，相信社区很快会有人写
	* XCode崩溃很多次，Playground基本没什么用，写注释都会崩
	* 报错不知所云，Int -> CGFloat 居然没有隐式转换。
	* 不知道Optional的用法(程序写的不够多的原因)

