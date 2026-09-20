# SAN値 Prolog (ver.2)マニュアル  
### last update: 2012/APR/24  
### 初出: 2012/APR/23  

### <a href="http://www.takeoka.org/~take/" target="_blank"> たけおか (竹岡尚三)</a>  

 <img src="nyaruko.jpg" WIDTH="250">


## 0. SAN値 Prolog について  

SAN値 Prologは、たけおかが考案した、SAN値論理に基づく論理型言語である。  

a. SAN値論理とは  
 SAN値とは「頭の正気度」を表す数値である。  
 SAN値が0だと、完全に気がアレである。  
<br>
 述語論理に「SAN値」というものを導入する。  
 SAN値論理では、評価時の「頭のおかしさ具合」を「SAN値」と呼ぶ。  
 各事実(節)ごとに、「SAN度」を設定できる。  
 <br>
 評価時にその時点のSAN値に、もっとも近いSAN度を持つ節が選ばれる。<br>
 SAN度を持つ述語の節は評価された後、その結果が真であったら、他の節とSAN度が比較される。<br>
 よって、SAN度を持つ述語の節はすべて評価される。<br>
 評価は、純粋な一階述語論理により行われる。よって、SAN度の付く節は、従来のpure Prologのような評価の順序に依存したプログラミングを行ってはいけない。



`90:partner(ニャル子).`    **←SAN値が90ぐらいで選ばれる**  
`60:partner(クー子).`    **←SAN値が60ぐらいで選ばれる**  
`30:partner(ハス太).`    **←SAN値が30ぐらいで選ばれる**  


論理式もOK
```
%%足し算が、正常にできるか?
90:plus(*X, *Y, *Z) :- *Z = *X + *Y .               ←SAN値が90ぐらいで選ばれる  
60:plus(*X, *Y, *Z) :- *Z1 = *X + *Y,  *Z = *Z1 +1 . ←SAN値が60ぐらいで選ばれる
30:plus(*X, *Y, *Z)  :- *Z = *X  ×  *Y .           ←SAN値が30ぐらいで選ばれる  
```

<br>
処理系は、以下で得られる。<br>
 <ul>
 <li><a href="http://www.takeoka.org/~take/ailabo/prolog/sanchi-prolog/sanchi-pro.lsp" target="_blank">
SAN値Prolog 処理系ソース (文字コードは、utf-8)</a>
 <li><a href="http://www.takeoka.org/~take/ailabo/prolog/sanchi-prolog/sanchi-prolog.pdf" target="_blank">
資料:「SAN値論理と名状しがたいSAN値Prolog」 </a>
 </ul>
<br><br>

 参考:
 <ul>
 <li><a href="http://nyaruko.com/" target="_blank">
名状しがたいアニメ「這いよれ！ニャル子さん」オフィシャルサイトのような ...
</a>
 <li><a href="http://ja.wikipedia.org/wiki/%E9%80%99%E3%81%84%E3%82%88%E3%82%8C!_%E3%83%8B%E3%83%A3%E3%83%AB%E5%AD%90%E3%81%95%E3%82%93" target="_blank">
Wikipedia:「這いよれ! ニャル子さん」の項</a>
 <li><a href="http://ja.wikipedia.org/wiki/%E3%82%AF%E3%83%88%E3%82%A5%E3%83%AB%E3%83%95%E3%81%AE%E5%91%BC%E3%81%B3%E5%A3%B0#.E6.AD.A3.E6.B0.97.E3.81.A8.E7.8B.82.E6.B0.97" target="_blank">
Wikipedia:「クトゥルフの呼び声#正気と狂気」の項</a>
 </ul>

<br>
<br>

## 1. 本SAN値 Prologの概略文法  
 SAN値Prologでは、SAN度を表す数値を、節の先頭に付ける。  
ただし、通常のPure Prologと同様の実行を期待する述語では、節の先頭に T を付ける。
これによって、通常のPrologのプログラムを正常に実行することが可能である。<br>
<br>
 本SAN値PrologはLispで記述しているので、述語、節、データはLispに準じて、すべてS式である。  


* Prolog変数は、"*"から始まるLispシンボル
* リストは、Lispのリストである。リストの car, cdr を分ける記号は"."。
* 節は、ヘッドとそれに続くボディ部の各項を一つのリストにする。<br>
   ヘッドは、ファンクタと引数をリストにする。<br>
   各項も、ファンクタと引数を、それぞれの項ごとに1つのリストにする。<br>
   例えば、通常のprologのappendは、

```
 append([],*x,*x).
 append([*a|*x], *y, [*a|*z]) :-  append(*x,*y,*z).
```

以下のように書く(S式に変形した後、節の先頭に T を付加する)
```
    ((T append () *x *x))
    ((T append (*a . *x) *y (*a . *z)) (append *x *y *z))))
```

* SAN度のついた節の次のようなProlog風記述
```
%%足し算が、正常にできるか?
90:plus(*X, *Y, *Z) :- *Z = *X + *Y .
60:plus(*X, *Y, *Z) :- *Z1 = *X + *Y,  *Z = *Z1 +1 .
30:plus(*X, *Y, *Z)  :- *Z = *X  ×  *Y .
```
は、下のように書く
```
((90 plus *x *y *z)(+ *x *y *z))
((60 plus *x *y *z)(+ *x *y *z1)(+ *z1 1 *z))
((30 plus *x *y *z)(mul *x *y *z))
```

* Pure Prologからの拡張  
  - Not演算子「~」がある。直後の節のリデュース結果の真偽を反転する。

<br>
<br>

## 2. SAN値 Prolog の制御  

本SAN値 Prolog の実行などを制御する関数などを下に揚げる。  
 <br>

### (sanchi-pro)
  本SAN値Prologの実行を開始する。<br>
  Lisp関数であり、Lispの top level から呼び出す。<br>
  プロンプトが出て、対話的に問い合わせができる。  
  プロンプトは、「にゃ?- 」。<br>
* プロンプトで、「end」を入力するとPrologを終了。
* プロンプトで、「trace」を入力すると、Prologの実行時に、トレース情報を表示する。
* プロンプトで、「notrace」を入力すると、Prologの実行時に、トレース情報を表示しない。
* シンボルを入力して、それが lisp変数としてバインド済みであれば、その内容を表示。
* 入力がlistであり、そのcarがlistでなければ、lisp S式としてLispで評価して、
結果を表示する。
* 入力が list で、そのcarも listであれば、それをゴール入力として、
Prologリダクションを始める。  <br>


### (pro-assert-new facts)  
  これまでの事実をクリアして、
事実データベース facts をアサートする。  
  Lisp関数。
  <br>

### (pro-assert facts)  
  事実データベース facts をアサートする。<br>
  これまでの事実は、クリアしない。<br>
  Lisp関数。<br>
  <br>

### (pro-trace t)  
 SAN値Prologの実行時に、トレース情報を表示するように指定する。<br>
  Lisp関数。  <br>
  <br>

### (pro-trace nil)  
  SAN値Prologの実行時に、トレース情報を表示しないように、指定。  <br>
  Lisp関数。  <br>
  <br>


## 3. 組込み述語、関数など  

Prolog中で使用できる組込み述語、組込み関数などを以下に掲げる。  


### \~ 節  
     Not。「\~」記号直後の節のリダクション結果の真偽を反転する。

###  (sanchi *x)  
      SAN値と引数をマッチングする。(ver.2 で追加)

### (set-sanchi *x)  
      引数の値をSAN値とする。(ver.2 で追加)

### (+ *x *y *z)
      数値加算 *z = *x + *y

### (- *x *y *z)
      数値減算 *z = *x - *y


### (mul *x *y *z)
      数値乗算 *z = *x * *y

### (/ *x *y *z)
     数値除算 *z = *x / *y

###  (< *x *y)
      数値比較  *x < *y

###  (<= *x *y)
      数値比較  *x <= *y

###  (=< *x *y)  
      数値比較  *x =< *y

### (> *x *y)  
      数値比較  *x > *y

### (>= *x *y)  
      数値比較  *x >= *y

###  (== *x *x)
      比較  *x == *y

### (read *z)  
     端末から read して、*z に入れる。read中は、実行は停止。

### (print *x)  
     端末へ print する。末尾で改行付き。

### (prin1 *x)  
 端末へ print する。改行無し。

### (terpri)  
     端末へ改行を出力。

  <br><br>



## 4. 事実データベース、節の例  

 事実データベースは、複数の節を一つのリストにしたものである。<br>
節は、ヘッドと複数のボディを一つのリストにしたものである。<br>
節であるリストの先頭の項がヘッドで、それに続く項の列がボディである。<br>

### 節の例
```
 ((t append (*a . *x) *y (*a . *z))  (append *x *y *z))
```

###  事実データベースの例
```
 (((t append () *x *x))
  ((t append (*a . *x) *y (*a . *z))   (append *x *y *z)) )
```

 事実は、Lispのtop levelや、prologのtop levelから、
```
(pro-assert-new
 '(
   ((t append () *x *x))
   ((t append (*a . *x) *y (*a . *z))   (append *x *y *z)) ))
```
 として、データベースに登録することができる。  
 これは、すなわち一度に複数の節をアサートすることである。  
 <br>
 <br>
 <br>



## 5. 文法  

### a) 変数  
   Prologの変数は 「*」から始まるシンボルである、<br>
  例: *x は変数である。

### b) リスト  
  Lispのlistが、そのままリストである。<br>
  「.」が car と cdr を分ける記号である。<br>
  例えば、 (*a . *x) と書くと、*aにリストの car が、*x にリストの cdr がマッチする。<br>

<br><br><br>
### 拡張BNF(AN)記法風 記述  
 <br>
 &lt;事実データベース&gt; ::= (&lt;節&gt; [&lt;節&gt;...]) <br>
 <br>
 &lt;節&gt; ::= (&lt;ヘッド&gt; [&lt;ボディ&gt;]) <br>
 <br>
 &lt;ヘッド&gt; ::= (&lt;ファンクタ&gt; [&lt;引数&gt;...]) <br>
 &lt;ボディ&gt; ::= (&lt;ファンクタ&gt; [&lt;引数&gt;...]) [&lt;ボディ&gt;...] <br>
 <br>
 &lt;引数&gt; ::=  &lt;定数&gt; | &lt;変数&gt; <br>
 <br>
 &lt;定数&gt; とは、 Lispシンボル、数、Lispリスト <br>
 &lt;変数&gt; とは、 「*」から始まるLispシンボル <br>


## 6. プログラム例  

### a) うーにゃー

SAN値が90あたりで、((90 foo "(」・ω・)」うー"))が選択され、<br>
SAN値が60あたりで、((60 foo "(／・ω・)／にゃー！"))が選択される。<br>
SAN値が30あたりで、((30 foo "xxx" ))))が選択される。<br>

```
%% Prolog的記述
  90:foo("(」・ω・)」うー").
  60:foo("(／・ω・)／にゃー！").
  30:foo("xxx").

;; 本SAN値Prologでのプログラム
(pro-assert-new
 '(
    ((90 foo "(」・ω・)」うー"))
    ((60 foo "(／・ω・)／にゃー！"))
    ((30 foo "xxx" ))))

```

### b) 足し算できるかな  

SAN値が90あたりで、正常な加算を行う節が選択され、<br>
SAN値が60あたりで、通常より1多く加える節が選択される。<br>
SAN値が30あたりで、2つの引数を乗算する節が選択される。<br>

```
%% Prolog的記述
  90:plus(*x,*y,*z) :- *z = *x + *y.
  60:plus(*x,*y,*z) :- *z1 = *x + *y, *z = *z1 + 1.
  30:plus(*x,*y,*z) :- *z = mul(*x ,  *y) .

;; 本SAN値Prologでのプログラム
(pro-assert-new
 '(
    ((90 plus *x *y *z)(+ *x *y *z))
    ((60 plus *x *y *z)(+ *x *y *z1)(+ *z1 1 *z))
    ((30 plus *x *y *z)(mul *x *y *z))))
```


### c) 普通の階乗  
通常Prologの階乗を行う。<br>

```
%% Prolog的記述
fa(0,1).
fa(*n,*x):- *n1 = *n - 1 ,fa(*n1,*x1), *x = *x1 * *n.

;; 本SAN値Prologでのプログラム(意味的には通常Prologのプログラム)
(pro-assert-new
 '(
    ((t fa 0 1))
    ((t fa *n *x) (- *n 1 *n1)(fa *n1 *x1)(mul *x1 *n *x))))
```

### d) ハノイの塔  
 パズル「ハノイの塔」を解く、通常 Pure Prologプログラム。<br>
```
%% Prolog的記述
hanoi(1,*f,*t,*v):-prin1(*f),prin1('->'),prin1(*t).
hanoi(*n,*f,*t,*v):-
        *n1= *n - 1,
        hanoi(*n1,*f,*v,*t),
        hanoi(1,*f,*t,*v),
        hanoi(*n1,*v,*t,*f).

;; 本SAN値Prologでのプログラム(意味的には通常Prologのプログラム)
(pro-assert-new
 '(((t hanoi 1 *f *t *v) (prin1 *f)(prin1 ->)(print *t))
   ((t hanoi *n *f *t *v)
        (- *n 1 *n1)
        (hanoi *n1 *f *v *t)
        (hanoi 1 *f *t *v)
        (hanoi *n1 *v *t *f))))
```

### e) SAN値の設定、参照
```
;; 本SAN値
(pro-assert-new
 '(
    ((t foo) (sanchi *x)(print *x))
    ((t bar *x)(set-sanchi *x)(foo))))
```
<br>
<br>


## 7. 実行例  

```
This is SBCL 1.0.50.0.debian, an implementation of ANSI Common Lisp.
More information about SBCL is available at &lt;http://www.sbcl.org/>.

SBCL is free software, provided as is, with absolutely no warranty.
It is mostly in the public domain; some portions are provided under
BSD-style licenses.  See the CREDITS and COPYING files in the
distribution for more information.
* (load "sanchi-pro.lsp")  ;;; 本処理系のロード

T
* (sanchi-pro)  ;;;処理系の起動

;;;;;;;;;;;; うーにゃー の例 ;;;;;;;;;;;;;;;
にゃ?-(pro-assert-new
 '(
    ((90 foo "(」・ω・)」うー"))
    ((60 foo "(／・ω・)／にゃー！"))
    ((30 foo "xxx" ))))

SAN値=90
lisp value=(((90 FOO "(」・ω・)」うー")) ((60 FOO "(／・ω・)／にゃー！")) ((30 FOO "xxx"))
            ((T + *X *Y *Z) (*SYSTEM-FUNC* PRO+ *X *Y *Z))
            ((T - *X *Y *Z) (*SYSTEM-FUNC* PRO- *X *Y *Z))
            ((T MUL *X *Y *Z) (*SYSTEM-FUNC* PRO* *X *Y *Z))
            ((T / *X *Y *Z) (*SYSTEM-FUNC* PRO/ *X *Y *Z))
            ((T < *X *Y) (*SYSTEM* < '*X '*Y))
            ((T <= *X *Y) (*SYSTEM* <= '*X '*Y))
            ((T =< *X *Y) (*SYSTEM* <= '*X '*Y))
            ((T > *X *Y) (*SYSTEM* > '*X '*Y))
            ((T >= *X *Y) (*SYSTEM* >= '*X '*Y)) ((T == *X *X))
            ((T READ *Z) (*SYSTEM-FUNC* PRO_READ *Z))
            ((T PRINT *X) (*SYSTEM* PROGN (FORMAT T "~s~%" '*X) T))
            ((T PRIN1 *X) (*SYSTEM* PROGN (FORMAT T "~s" '*X) T))
            ((T TERPRI) (*SYSTEM* PROGN (FORMAT T "~%") T)))
にゃ?-(set-sanchi 90)  ;;; SAN値を90にセット
SAN値=90
lisp value=90
にゃ?-((foo *x))       ;;; うーにゃーの実行
SAN値=90
 - new-head=(FOO "(」・ω・)」うー") sanchi=90 
 - choiced-clause=((90 FOO "(」・ω・)」うー"))  ;;; SAN度90の節が選ばれた
 - new-head=(FOO "(／・ω・)／にゃー！") sanchi=60 
 - new-head=(FOO "xxx") sanchi=30 

result=T
reduced-goal=((FOO "(」・ω・)」うー"))  ;;; 最終的に「うー」が選ばれた

にゃ?-(set-sanchi 65)  ;;; SAN値を65にセット
SAN値=90
lisp value=65
にゃ?-((foo *x))       ;;; うーにゃーの実行
SAN値=65
 - new-head=(FOO "(」・ω・)」うー") sanchi=90 
 - choiced-clause=((90 FOO "(」・ω・)」うー"))   ;;; まず、SAN度90の節が選ばれた
 - new-head=(FOO "(／・ω・)／にゃー！") sanchi=60 
 - choiced-clause=((60 FOO "(／・ω・)／にゃー！"))    ;;; SAN度がSAN値(65)に、より近い60の節が選ばれた
 - new-head=(FOO "xxx") sanchi=30 

result=T
reduced-goal=((FOO "(／・ω・)／にゃー！"))  ;;; 最終的に「にゃー」が選ばれた

にゃ?-(set-sanchi 25)  ;;; SAN値を25にセット
SAN値=65
lisp value=25
にゃ?-((foo *x))       ;;; うーにゃーの実行
SAN値=25
 - new-head=(FOO "(」・ω・)」うー") sanchi=90 
 - choiced-clause=((90 FOO "(」・ω・)」うー"))    ;;; まず、SAN度90の節が選ばれた
 - new-head=(FOO "(／・ω・)／にゃー！") sanchi=60 
 - choiced-clause=((60 FOO "(／・ω・)／にゃー！"))     ;;; SAN度がSAN値に、より近い60の節が選ばれた
 - new-head=(FOO "xxx") sanchi=30 
 - choiced-clause=((30 FOO "xxx"))      ;;; 最終的に、SAN度がSAN値(25)に、もっとも近い30の節が選ばれた

result=T
reduced-goal=((FOO "xxx"))  ;;; 最終的に"xxx"が選ばれた




;;;;;;;;;;;; 足し算できるかな の例 ;;;;;;;;;;;;;;;
にゃ?-(pro-assert-new
 '(
    ((90 plus *x *y *z)(+ *x *y *z))
    ((60 plus *x *y *z)(+ *x *y *z1)(+ *z1 1 *z))
    ((30 plus *x *y *z)(mul *x *y *z))))

SAN値=25
lisp value=(((90 PLUS *X *Y *Z) (+ *X *Y *Z))
            ((60 PLUS *X *Y *Z) (+ *X *Y *Z1) (+ *Z1 1 *Z))
            ((30 PLUS *X *Y *Z) (MUL *X *Y *Z))
            ((T + *X *Y *Z) (*SYSTEM-FUNC* PRO+ *X *Y *Z))
            ((T - *X *Y *Z) (*SYSTEM-FUNC* PRO- *X *Y *Z))
            ((T MUL *X *Y *Z) (*SYSTEM-FUNC* PRO* *X *Y *Z))
            ((T / *X *Y *Z) (*SYSTEM-FUNC* PRO/ *X *Y *Z))
            ((T < *X *Y) (*SYSTEM* < '*X '*Y))
            ((T <= *X *Y) (*SYSTEM* <= '*X '*Y))
            ((T =< *X *Y) (*SYSTEM* <= '*X '*Y))
            ((T > *X *Y) (*SYSTEM* > '*X '*Y))
            ((T >= *X *Y) (*SYSTEM* >= '*X '*Y)) ((T == *X *X))
            ((T READ *Z) (*SYSTEM-FUNC* PRO_READ *Z))
            ((T PRINT *X) (*SYSTEM* PROGN (FORMAT T "~s~%" '*X) T))
            ((T PRIN1 *X) (*SYSTEM* PROGN (FORMAT T "~s" '*X) T))
            ((T TERPRI) (*SYSTEM* PROGN (FORMAT T "~%") T)))
にゃ?-(set-sanchi 90)  ;;; SAN値を90にセット
SAN値=25
lisp value=90
にゃ?-((plus 2 4 *x))       ;;; 2+4=? の実行
SAN値=90
 - new-head=(PLUS *X *Y *Z) sanchi=90 
 - choiced-clause=((90 PLUS 2 4 6) (+ 2 4 6))   ;;; SAN度90の節が選ばれた
 - new-head=(PLUS *X *Y *Z) sanchi=60 
 - new-head=(PLUS *X *Y *Z) sanchi=30 

result=T
reduced-goal=((PLUS 2 4 6))  ;;; 最終的に正しい加算が選ばれた

にゃ?-(set-sanchi 65)  ;;; SAN値を65にセット
SAN値=90
lisp value=65
にゃ?-((plus 2 4 *x))       ;;; 2+4=? の実行
SAN値=65
 - new-head=(PLUS *X *Y *Z) sanchi=90 
 - choiced-clause=((90 PLUS 2 4 6) (+ 2 4 6))     ;;; まず、SAN度90の節が選ばれた
 - new-head=(PLUS *X *Y *Z) sanchi=60 
 - choiced-clause=((60 PLUS 2 4 7) (+ 2 4 6) (+ 6 1 7))      ;;; SAN度がSAN値に、より近い60の節が選ばれた
 - new-head=(PLUS *X *Y *Z) sanchi=30 

result=T
reduced-goal=((PLUS 2 4 7))  ;;; 最終的に2+4=7、すなわちSAN値60の節が選ばれた

にゃ?-(set-sanchi 25)  ;;; SAN値を25にセット
SAN値=65
lisp value=25
にゃ?-((plus 2 4 *x))       ;;; 2+4=? の実行
SAN値=25
 - new-head=(PLUS *X *Y *Z) sanchi=90 
 - choiced-clause=((90 PLUS 2 4 6) (+ 2 4 6))     ;;; まず、SAN度90の節が選ばれた
 - new-head=(PLUS *X *Y *Z) sanchi=60 
 - choiced-clause=((60 PLUS 2 4 7) (+ 2 4 6) (+ 6 1 7))      ;;; SAN度がSAN値に、より近い60の節が選ばれた
 - new-head=(PLUS *X *Y *Z) sanchi=30 
 - choiced-clause=((30 PLUS 2 4 8) (MUL 2 4 8))       ;;; 最終的に、SAN度がSAN値(25)に、もっとも近い30の節が選ばれた

result=T
reduced-goal=((PLUS 2 4 8))  ;;; 最終的に2*4=8、を実行した節(SAN度30)が選ばれた



;;;;;;;;;;;; 普通のハノイの塔 の例 ;;;;;;;;;;;;;;;
にゃ?-(pro-assert-new
 '(
    ((t hanoi 1 *f *t *v) (prin1 *f)(prin1 ->)(print *t))
    ((t hanoi *n *f *t *v) (- *n 1 *n1)
          (hanoi *n1 *f *v *t)
	  (hanoi 1 *f *t *v)
	  (hanoi *n1 *v *t *f))))

SAN値=25
lisp value=(((T HANOI 1 *F *T *V) (PRIN1 *F) (PRIN1 ->) (PRINT *T))
            ((T HANOI *N *F *T *V) (- *N 1 *N1) (HANOI *N1 *F *V *T)
             (HANOI 1 *F *T *V) (HANOI *N1 *V *T *F))
            ((T + *X *Y *Z) (*SYSTEM-FUNC* PRO+ *X *Y *Z))
            ((T - *X *Y *Z) (*SYSTEM-FUNC* PRO- *X *Y *Z))
            ((T MUL *X *Y *Z) (*SYSTEM-FUNC* PRO* *X *Y *Z))
            ((T / *X *Y *Z) (*SYSTEM-FUNC* PRO/ *X *Y *Z))
            ((T < *X *Y) (*SYSTEM* < '*X '*Y))
            ((T <= *X *Y) (*SYSTEM* <= '*X '*Y))
            ((T =< *X *Y) (*SYSTEM* <= '*X '*Y))
            ((T > *X *Y) (*SYSTEM* > '*X '*Y))
            ((T >= *X *Y) (*SYSTEM* >= '*X '*Y)) ((T == *X *X))
            ((T READ *Z) (*SYSTEM-FUNC* PRO_READ *Z))
            ((T PRINT *X) (*SYSTEM* PROGN (FORMAT T "~s~%" '*X) T))
            ((T PRIN1 *X) (*SYSTEM* PROGN (FORMAT T "~s" '*X) T))
            ((T TERPRI) (*SYSTEM* PROGN (FORMAT T "~%") T)))
にゃ?-((hanoi 3 a b via))      ;;; ハノイの実行
SAN値=25
A->B
A->VIA
B->VIA
A->B
VIA->A
VIA->B
A->B

result=T
reduced-goal=((HANOI 3 A B VIA))

にゃ?-

;;; Prologの終了は「end」を入力する
にゃ?-end
SAN値=25
T
* 
```


## 8. その他

この処理系(実行系)は、Prologとしては非常に素朴で、全然、性能は良くありません。(と言うより、むしろ悪い)<br>
この実行系は、テール・リカーシブ・インタープリタになっていません。<br>
<br>
開発には、SBCLを使用しました。  
 <br>
以上  
