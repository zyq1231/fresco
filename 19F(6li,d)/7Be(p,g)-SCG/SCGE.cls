\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{SCGE}[2008/11/15 v1]

\LoadClass[twoside]{article} %% math packages 
\RequirePackage{amsmath,color,amsthm,upgreek,amsfonts,tabularx,amssymb,geometry,times,txfonts,cite} 
%% graphics packages 
\RequirePackage{graphicx} 
%\usepackage{graphicx}
%% other packages 
\RequirePackage{url,float} %% check pdfTeX mode 
\RequirePackage{ifpdf}

\usepackage{multicol}
\usepackage{balance}

%\usepackage{afterpage} %%(11月注释：使所有未处理的浮动对象在下一分页前被清除完)
\usepackage{placeins} %%(11月注释：图表浮动宏包)


\columnsep 0.7cm  %两栏之间的距离

%----------------------------------图表相关-----------------------------

%\usepackage{flushend}%%(11月注释：双栏对齐宏包，此处不起作用)
%\usepackage{balance}%%(11月注释：双栏对齐宏包，此处不起作用)
\usepackage{booktabs}%%(11月注释：表格宏包，可调整表格中的线宽)
\usepackage{caption2}%%(11月注释：标题宏包)
\renewcommand{\captionlabeldelim}{~~~}%%(11月注释：定义标题编号与标题间空三格)
\captionstyle{normal} %%(11月注释：标题两边对齐，最后一行左对齐)
\renewcommand{\captionfont}{\footnotesize}%%(11月注释：小号标题)
\renewcommand{\captionlabelfont}{\footnotesize \bfseries}%%(11月注释：小号黑体标题编号)
%%\usepackage{caption}%%(11月注释：标题宏包，可调整标题字体字号)
%%\DeclareCaptionLabelSeparator{twospace}{~~}%%(11月注释：定义标题编号与标题间空两格)
%%\captionsetup{labelsep=twospace}%%(11月注释：标题编号与标题间空两格)
  
  
  %%(11月注释：适当放宽图形环境中的各种比例参数)
\renewcommand{\textfraction}{0.15} 
\renewcommand{\topfraction}{0.85} 
\renewcommand{\bottomfraction}{0.65} 
\renewcommand{\floatpagefraction}{0.60}


%------------------------ Page layout ----------------------------------

\textwidth=178truemm
\textheight=227truemm
\topmargin=-76pt
\headsep=5truemm
\oddsidemargin=-26pt
\evensidemargin=-26pt
\parindent=0pt
\footskip=0mm
\renewcommand{\baselinestretch}{1.06}
\renewcommand{\arraystretch}{1.2}
\newcommand{\xiaosanhao}{\fontsize{15pt}{2\baselineskip}\selectfont}
\newcommand{\sanhao}{\fontsize{16pt}{2\baselineskip}\selectfont}
\newcommand{\xiaosihao}{\fontsize{12pt}{\baselineskip}\selectfont}
\newcommand{\wuhao}{\fontsize{10pt}{\baselineskip}\selectfont}
%\newcommand{\sanhao}{\fontsize{18pt}{\baselineskip}\selectfont}
\newcommand{\bahao}{\fontsize{8pt}{\baselineskip}\selectfont}
\newcommand{\qihao}{\fontsize{7pt}{\baselineskip}\selectfont}
\newcommand{\jiuhao}{\fontsize{9pt}{0.8\baselineskip}\selectfont}
\newcommand{\jiuwuhao}{\fontsize{9.9pt}{0.8\baselineskip}\selectfont}

\doublerulesep=0pt 

%----------------------- Title Page ----------------------------------

\let\@Year\@empty \def\Year#1{\def\@Year{#1}}\let\@Month\@empty 
\def\Month#1{\def\@Month{#1}} \let\@Vol\@empty 
\def\Vol#1{\def\@Vol{#1}} \let\@No\@empty \def\No#1{\def\@No{#1}} 
\let\@AuthorMark\@empty \def\AuthorMark#1{\def\@AuthorMark{#1}}
\let\@AuthorMarkCite\@empty \def\AuthorMarkCite#1{\def\@AuthorMarkCite{#1}}%(11月注释：citation中的作者记号) 
\let\@BeginPage\@empty \def\BeginPage#1{\def\@BeginPage{#1}} 
\let\@EndPage\@empty \def\EndPage#1{\def\@EndPage{#1}} 
\let\@DOI\@empty \def\DOI#1{\def\@DOI{#1}} 
\def\th#1{\vspace{1mm}\noindent{\bf #1}\quad } 
\def\REF#1{\par\hangindent\parindent\indent\llap{#1\enspace}}


\let\@title\@empty 
\renewcommand\title[2][]{
  \renewcommand{\baselinestretch}{0.9}
  \baselineskip 9pt
  %============
    \vspace{-7mm}
  \begin{picture}(0,0){\rm{\bfseries
 \put(195.4,7){\sanhao {\textcolor[rgb]{0.39,0.39,0.39}{SCIENCE CHINA}}}}
\put(152.5,-9.8){\xiaosanhao\sf{Physics, Mechanics \& Astronomy}}
\put(0,-17){\thicklines\line(1,0){506}}
%\put(0,-32){\makebox[178truemm][l]{\bf{\bfseries 
%{\sanhao\raisebox{2pt}{.}} Research Papers $ 
%{\sanhao\raisebox{1.5pt}{.}}$}}} 
\put(0,-30){\makebox[178truemm][r]{\vbox{\hbox{\footnotesize 
\@Month~\@Year~~Vol.\,\@Vol~~No.\,\@No: \@BeginPage--\@EndPage}}}}} 
\put(0,-41){\makebox[178truemm][r]{\vbox{\hbox{\footnotesize  doi: 
~\@DOI}}}} \put(0,-674){\scriptsize\sf$\copyright$~Science China 
Press and Springer-Verlag Berlin Heidelberg \@Year} 
\put(0,-674.5){\makebox[178truemm][r]{\scriptsize\sf 
phys.scichina.com~~~~link.springer.com}} 
\end{picture}\def\no{\noindent}
 
 
  %===============

  \vskip 17true mm
  \def\@title{#2}
  \def\@titlehead{#1}
  \ifx\@titlehead\@empty\def\@titlehead{#2}\fi
}
\let\@author\@empty
\renewcommand*{\author}[3][]{%
  \ifx \@author\@empty
    \def\@author{#2\@authornote{#1}{#3}}
    \let\@authortemp\@author
    \def\@authorhead{#2}
    \let\@authorheadtemp\@authorhead
  \else
    \let\@author\@authortemp
    \let\@authorhead\@authorheadtemp
    \expandafter\def\expandafter\@author\expandafter
      {\@author~{\upshape\&}~#2\@authornote{#1}{#3}}
    \expandafter\def\expandafter\@authortemp\expandafter
      {\@authortemp, #2\@authornote{#1}{#3}}
    \expandafter\def\expandafter\@authorhead\expandafter
      {\@authorhead~{\upshape\&}~#2}
    \expandafter\def\expandafter\@authorheadtemp\expandafter
      {\@authorheadtemp, #2}
  \fi
}
\def\@authornote#1#2{%
  \def\SCAE@author@address{#1}%
  \def\SCAE@author@footnote{#2}%
  \ifx \SCAE@author@address\@empty
    \ifx \SCAE@author@footnote\@empty
    \else
      \footnote{\scriptsize#2}%
    \fi
  \else
    \textsuperscript{#1}%
    \ifx \SCAE@author@footnote\@empty
    \else
      %\textsuperscript{,}%
      \footnote{\scriptsize#2}%
    \fi
  \fi}
\def\@address{}
\newcommand*{\address}[2][]{%
  \ifx \@address\@empty
    \def\@address{\@addressline{#1}{#2}}
  \else
    \expandafter\def\expandafter\@address\expandafter
      {\@address\tabularnewline\@addressline{#1}{#2}}
  \fi}
\def\@addressline#1#2{\@addresscr\hb@xt@1ex{\textsuperscript{#1}\hss}#2}
\def\@addresscr{\def\\{\tabularnewline\@addresscr\hbox to1ex{}\ignorespaces}}
\def\@foundation{}
\newcommand*{\foundation}[1]{
  \def\SCAE@foundation{#1}
  \ifx\SCAE@foundation\@empty
  \else  
    \def\@foundation{\footnotetext{#1}}
  \fi
}
\renewcommand\maketitle{\par
  \begingroup
    \renewcommand\thefootnote{\@fnsymbol\c@footnote}%
    \def\@makefnmark{\hbox{\@textsuperscript{\normalfont\@thefnmark}}}%
    \long\def\@makefntext##1{\noindent\@textsuperscript{\normalfont\@thefnmark}##1}%
    \@maketitle
    \thispagestyle{empty}\@thanks
    \long\def\@makefntext##1{\noindent##1}%
    \@foundation
  \endgroup
  \setcounter{footnote}{0}%
  \setcounter{page}{\@BeginPage}
}
\def\@maketitle{%
  \begingroup\noindent%
    \let\footnote\thanks
    {\vskip20mm\begin{center}\LARGE\bfseries \@title \end{center}}%
    {\begin{center}\xiaosihao  \rm
      \begin{tabular}[t]{@{}c@{}}%
        \@author
      \end{tabular}\end{center}}%
    {\begin{center}\bahao{ \it 
      \begin{tabular}[t]{@{}c@{}}%
        \@address
      \end{tabular}} \end{center}}%%
  \endgroup
}


%----------------------- Running heads ---------------------------------
\def\ps@myheadings{\global\let\@oddfoot\@empty\global\let\@evenfoot\@empty
\def\@evenhead{\vbox{\hbox to \textwidth{\textsf{\jiuhao\thepage}\qihao\rm\hbox to
0.01cm{} \hfill{\emph{\@AuthorMark ~~~~~ Sci China-Phys Mech Astron}
{ ~~~~\@Month ~(\@Year) ~~~Vol.~\@Vol ~~~ No.~\@No~
}}\hfill}}}
\def\@oddhead{\vbox{\hbox to \textwidth{\qihao\rm\hbox to
0.01cm{} \hfill{\emph{\@AuthorMark~~~~~ Sci China-Phys Mech Astron}
{ ~~~~\@Month ~(\@Year) ~~~Vol.~\@Vol ~~~ No.~\@No~
}}\hfill\textsf{\jiuhao\thepage}}}}
\let\@oddfoot\@empty  \let\@evenfoot\@empty
} 
\pagestyle{myheadings}

%-------------------------- Abstract ----------------------------------
\renewenvironment{abstract}
   {\trivlist\itemindent\parindent\item\relax%
    \renewcommand{\baselinestretch}{0.95}\baselineskip 15pt
     \jiuhao\noindent\ignorespaces}
  {\endtrivlist}
\newcommand*\keywords[1]{%
  {\renewcommand{\baselinestretch}{0.95}\baselineskip 12pt
     \noindent{\jiuhao\bf\quad #1\par}}}
     
\newcommand*\PACS[1]{%
 \parbox{16.4cm}
  {      \jiuhao{\noindent \textbf{PACS number(s):} ~#1}}
    \baselineskip 11pt \selectfont
    \vspace*{-3.0mm}
\begin{center}
\rule{16.5cm}{0.4pt}
\end{center}
\vspace*{-2.5mm}
}

\newcommand*\CITA{%
  \parbox[t]{1.35cm}{\scriptsize{\noindent \textbf{Citation:}}}
  \parbox[t]{15.0cm}{\scriptsize{\@AuthorMarkCite ~\@title.~Sci China-Phys
   Mech Astron,~\@Year,~\@Vol:~\@BeginPage--\@EndPage,~doi:\@DOI} \newline\newline}
    \baselineskip 11pt \selectfont 
    \vspace*{-5.6mm}
\begin{center}
\rule{16.5cm}{0.4pt}
\end{center}
}    %%(11月注释：自动citation)

\newcommand*\Cit[1]{%
\parbox[t]{1.35cm}{\scriptsize{\noindent \textbf{Citation:}}}
  \parbox[t]{15.0cm}{\scriptsize{#1} \newline\newline}
    \baselineskip 11pt \selectfont 
    \vspace*{-5.6mm}
\begin{center}
\rule{16.5cm}{0.4pt}
\end{center} 
}          %%(11月注释：手动citation)

\newcommand*\Acknowledgements[1]{%
  {\vskip 0.75cm
    \baselineskip 12pt \renewcommand{\baselinestretch}{1.18}
    {\jiuhao\noindent{\it
    #1}}\par}}
    
    
%-------------------------- Sections ----------------------------------
%\renewcommand\section{\@startsection {section}{1}{\z@}%
%                                   {-4ex \@plus -1ex \@minus -.2ex}%
%                                   {3ex \@plus.1ex}%
%                                   {\normalfont\xiaosihao\bfseries}}
%\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
%                                     {-2.8ex\@plus -1ex \@minus -.1ex}%
%                                     {1.5ex \@plus .1ex}%
%                                     {\normalfont\normalsize\bfseries}}
%\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
%                                    {-2ex\@plus -1ex \@minus -.1ex}%
%                                   {0.1ex \@plus .1ex}%
%                                  {\normalfont\normalsize\it}} 

\usepackage{titlesec}
\titleformat{\section}[block]{\normalfont\xiaosihao\bfseries}{\thesection}{0.63em}{ }[ ]
\titleformat{\subsection}[block]{\normalfont\normalsize\bfseries}{\thesubsection}{0.6em}{ }[ ]
\titleformat{\subsubsection}[block]{\normalfont\normalsize\it}{\thesubsubsection}{0.5em}{ }[ ]

\def\sec#1{\vspace{7mm}\noindent{{\xiaosihao\rm\bfseries{#1}}}\vspace{4mm}}% 定义一级章节
\def\subsec#1{\vspace{5mm}\noindent{\normalsize\bfseries#1}\vspace{2mm}} %定义二级章节
\def\subsubsec#1{\vspace{4mm}\noindent{\it #1}\vspace{1mm}}%定义三级章节




%----------------------- thebibliography ---------------------------------

\def\@biblabel#1{#1~}
 \renewenvironment{thebibliography}[1]
     {\vspace{0.4cm}
            \list{\@biblabel{\@arabic\c@enumiv}}%
           {\settowidth\labelwidth{\@biblabel{#1}}%
            \leftmargin \labelwidth
            \advance\leftmargin\labelsep
            \@openbib@code
            \usecounter{enumiv}%
             \let\p@enumiv\@empty
             \renewcommand\theenumiv{\@arabic\c@enumiv}
            }%
      \itemsep 0.2ex
      \parskip 0ex
      \footnotesize
      \sloppy}   
      
      
      

%----------------------- Math ---------------------------------
\def\leq{\leqslant}
\def\geq{\geqslant}
\def\le{\leqslant}
\def\ge{\geqslant}
\abovedisplayskip=12pt plus 5pt minus 8pt 
\belowdisplayskip=12pt plus 5pt minus 8pt 
\newcommand{\set}[1]{\ensuremath{\left\{ #1 \right\}}}%
\newcommand{\Set}[2]{\ensuremath{\left\{ #1 \left| \right. #2 \right\}}}%
\newcommand{\abs}[1]{\ensuremath{\left| #1 \right|}}%
\newcommand{\map}[3]{\ensuremath{#1 : #2 \rightarrow #3}}%
\newcommand{\C}[1]{\ensuremath{\mathcal{#1}}}%
\newcommand{\restrict}[2]{\ensuremath{#1 \left|_{#2}\right.}}%
\newcommand{\NN}{\mathbb{N}^0}
\newcommand{\PN}{\mathbb{N}}
\newcommand{\syn}{\mathbf{S}}
\newcommand{\Syn}{\mathbf{M}}
\allowdisplaybreaks

%----------------------- Theorems ---------------------------------
\newtheorem{thm}{Theorem}[section]%
\newtheorem{cor}[thm]{Corollary}%
\newtheorem{lem}[thm]{Lemma}%
\newtheorem{prop}[thm]{Proposition}%
\newtheorem{prob}[thm]{Problem}
\theoremstyle{definition}%
\newtheorem{defn}[thm]{Definition}%
\newtheorem{rem}[thm]{Remark}%
\newtheorem{exa}[thm]{Example}%

%----------------------- Others ---------------------------------
\newenvironment{listnum}{%
\begin{list}{{\rm(\arabic{enumi})}}{%
\usecounter{enumi}%
\labelwidth=4em%
\labelsep=0.5em%
\leftmargin=0em%
\rightmargin=0em%
\parsep=\parskip%
\itemsep=0ex
\topsep=0em%
\itemindent=3.2em%
}%
}{\end{list}}%

\newenvironment{listroman}{%
\begin{list}{{\rm(\roman{enumi})}}{%
\usecounter{enumi}%
\labelwidth=4em%
\labelsep=0.5em%
\leftmargin=3em%
\rightmargin=2em%
\parsep=\parskip%
\itemsep=0ex
\topsep=0em%
}%
}{\end{list}}%


%----------------------------------------------------
\makeatletter
\newenvironment{tablehere}
  {\def\@captype{table}}
 {}

\newenvironment{figurehere}
 {\def\@captype{figure}}
 {}
\makeatother



\endinput
