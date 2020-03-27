\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jtlu-article-2col}[2011/07/20 Journal of Transport and Land Use v2.1]
\typeout{Document class for articles in the Journal of Transport and Land Use (v2.1, July 2011)}

%% ============= Base class is paper.cls from ''journal'' package on CTAN/TexLIVE ====== %%
% Set basic options:
\LoadClass[11pt,twocolumn,twoside,notitlepage]{paper} % Base documentclass w/options

%% =========== Generate the issue info and article copyright from === %%
%% =========== tags in the document source:  ======================== %%
\newcommand\makeissueinfo{%
\flushleft\footnotesize {\scshape the journal of transport and land use} \hspace{.8em} \url{http://jtlu.org}\\[.3ex]
{\scshape vol.~{\@jtluvolume} no.~{\@jtluissue}} [\@jtluquarter{}~\@jtluyear{}] pp.~\thepage--\pageref*{LastPage} \hspace{.8em}\doi{10.5198/jtlu.v{\@jtluvolume}i{\@jtluissue}.{\@jtluid}}
}

% Compatibility with Writer2LaTeX math  export (better to re-set equations  manually though): 
\newcommand\normalsubformula[1]{\text{\mathversion{normal}$#1$}}

% Notes at the bottom of figures and tables:
\newcommand\floatnote[1]{\captionsetup{singlelinecheck=off,format=plain,position=bottom,skip=5pt,margin=.01\linewidth}\caption*{#1}}

% Macro to remove vertical spacing around lists inside table cells:
\newcommand*{\compress}{\@minipagetrue}



% \newcommand\makeissueinfo{%
% \flushleft\footnotesize\JTLU{} vol.~{\@jtluvolume} no.~{\@jtluissue} [\@jtluquarter{}~\@jtluyear{}] pp.~\thepage--\pageref*{LastPage} \\[.5ex] %
% \url{http://jtlu.org}\hspace{.5em}|\hspace{.5em}\doi{\@jtludoi{}}
% }

%% ============= Set up options for editorial review and final layout modes ========= %%
% The "edit" option causes the article to be output on US Letter size paper
% with line numbers, a special header on the first page, and "draft" footers.
% The "layout" mode uses B5 paper, no line numbers, normal first page and no footers.
%
% Options for edit mode:
\DeclareOption{edit}{% 
	% Options for the geometry package, specifying page layout in draft mode:
	\PassOptionsToPackage{letterpaper,includeheadfoot,%
		textwidth=185mm,height=255mm,top=15mm,marginparwidth=35mm,left=15mm}{geometry}%
	% Formatting author queries in the margin:
	\newcounter{querycounter}\setcounter{querycounter}{1} % Number the queries
	\newcommand{\query}[1]{\marginpar{%
	\vskip-\baselineskip % Raise the marginpar a bit
	\raggedright\footnotesize%
	\itshape\hrule\smallskip{\arabic{querycounter}. }#1\par\smallskip\hrule\stepcounter{querycounter}}}%
	% Commands to be executed immediately following \begin{document}:
	\AtBeginDocument{
		\pagestyle{fancy} % Turn on fancyhead
		\pagewiselinenumbers %\switchlinenumbers* % Configure line numbering
		\fancyfoot[C]{\sf\large DRAFT -- FOR AUTHOR REVIEW}} % Add draft footer
	% Special stuff for first page of article:	
	\newcommand\ps@firstpage{% Format first page, edit mode
 		\let\@evenhead\@empty\let\@oddhead\@empty%
		% \def\@oddfoot{%
 		% 	\vbox{\raggedright\footnotesize Copyright \@jtluyear{} \@jtlurights.\linebreak Licensed under the
   		% 	\cclicense{}.}}
                \def\@oddfoot{\parbox[b]{\textwidth}{\footnotesize Copyright
                  \@jtluyear{} \@jtlurights.\newline Licensed under
                  the \cclicense{}.}}
                \def\@oddhead{\raisebox{20\p@}[\z@]{%
			\begin{minipage}[t]{0.7\textwidth}\vspace{4pt}\large\sf FOR AUTHOR REVIEW\newline Scheduled for JTLU \@jtluvolume{}.\@jtluissue{}\end{minipage}
	\begin{minipage}[t]{0.3\textwidth}\vspace{0pt}\hfill\includegraphics{jtlu-logo-red}\end{minipage}
	}}}		
	}
%	
% Options for final layout mode:
\DeclareOption{galley}{%
	% Options for geometry package, specifying page layout when run in "layout" mode:
	\PassOptionsToPackage{letterpaper,includeheadfoot,%
		textwidth=185mm,height=255mm,top=15mm,marginparwidth=35mm,left=15mm}{geometry}%
	% Discard any author queries left over from editing:
	\newcommand{\query}[1]{}
	% Special stuff for first page of article:
	\newcommand\ps@firstpage{% Format first page, layout mode
 		\let\@evenhead\@empty\let\@oddhead\@empty%
                \def\@oddfoot{\parbox[b]{\textwidth}{\footnotesize Copyright
                  \@jtluyear{} \@jtlurights.\newline Licensed under
                  the \cclicense{}.}}
 		\def\@oddhead{\raisebox{20\p@}[\z@]{% First page header
			\begin{minipage}[t]{0.7\textwidth}\vspace{4pt}\makeissueinfo\end{minipage}
			\begin{minipage}[t]{0.3\textwidth}\vspace{0pt}\hfill\includegraphics{jtlu-logo-red}\end{minipage}
	}}}
	% Commands to be executed immediately following \begin{document}:	
 \AtBeginDocument{ 
  	\pagestyle{fancy} % Turn on fancyhead
	}}
% 	
\ProcessOptions\relax % Now, do all of the above and move on...
%% ============= End of options section ============ %%

%% ============= Load a variety of useful packages =========== %%
% These packages should be available in a standard TeXLive or MacTeX installation. If not, download from CTAN.

% Extra tools for eTeX:
\RequirePackage{etoolbox}

% Page layout and typography:
\RequirePackage{geometry} % Basic page dimensions
\RequirePackage[urw-garamond]{mathdesign} % Math mode fonts = URW-Garamond to match Adobe Garamond body text. Load before fontspec.
\RequirePackage[no-math]{fontspec}% Font control. Let mathdesign handle math; need recent fontspec for no-math option.
\RequirePackage{xltxtra,xunicode} % XeTeX extras
\RequirePackage{amsmath} % Math typesetting 
\RequirePackage{lscape} % For landscape page layout, e.g. wide multipage tables/figures
\RequirePackage{fancyhdr} % Page formatting, running heads
\RequirePackage{lastpage} % To get number of last page for the first page header
\RequirePackage{placeins} % For float placement control
\RequirePackage{lineno} % Marginal line numbering in edit mode
\RequirePackage[defblank]{paralist} % Additional list environments
\RequirePackage{siunitx} % SI units, number separators, and help with tabular numbers
\RequirePackage{enumitem} % Extended list formatting

% Graphics and color:
\RequirePackage{graphicx} % Handling external graphics files
\RequirePackage{subfig} % Multi-part figures and tables
\RequirePackage[xetex,hyperref,dvipsnames,table]{xcolor} % Color handling
\RequirePackage[figuresright]{rotating} % To rotate tables and figures

% Tables:
\RequirePackage{array} % Extensions to LaTeX tabular
\RequirePackage{longtable} % Multi-page tables (tricky in 2-column layout mode though)
\RequirePackage{multirow} % Table cells spanning multiple rows
\RequirePackage{makecell} % Handy for multi-line table cells, one-cell tables-in-tables, etc.
\RequirePackage{tabu} % Variable-width tables
\RequirePackage[referable]{threeparttablex} % Modified threeparttable.sty for table notes in tabu/longtable environments
\RequirePackage{booktabs} % Nice table layout w/horizontal rules & spacing

% Bibliographic: 
% (Also, use the jtlu.bst style file to format the references list)
\RequirePackage[sort]{natbib} % Author-date references
\RequirePackage{hypernat} % Make hyperref and natbib work together; hyperlinks in the references list

% Hyperlinks:
\RequirePackage[xetex]{hyperref} % Hyperlinks; load this last to prevent overwriting pdf options (auto-loads url package)
\RequirePackage{doipubmed} % DOIs and PubMed IDs formatted and hyperlinked, like URLs

%% ============== Define global variables for issue and article info === %%
% I based this on paper.cls; don't know if it's the best way but it works.
\global\let\@jtluvolume\@empty
\global\let\jtluvolume\relax
\global\let\@jtluissue\@empty
\global\let\jtluissue\relax
\global\let\@jtluquarter\@empty
\global\let\jtluquarter\relax
\global\let\@jtluyear\@empty
\global\let\jtluyear\relax
\global\let\@jtlurights\@empty
\global\let\jtlurights\relax
\global\let\@jtluid\@empty
\global\let\jtluid\relax

\def\@jtluvolume{}   \def\jtluvolume#1{\gdef\@jtluvolume{#1}}
\def\@jtluissue{}    \def\jtluissue#1{\gdef\@jtluissue{#1}}
\def\@jtluquarter{}  \def\jtluquarter#1{\gdef\@jtluquarter{#1}}
\def\@jtluyear{}     \def\jtluyear#1{\gdef\@jtluyear{#1}}
\def\@jtlurights{}   \def\jtlurights#1{\gdef\@jtlurights{#1}}
\def\@jtluid{}      \def\jtluid#1{\gdef\@jtluid{#1}}

%% ========== Change default page break parameters to discourage widow/orphan lines ====== %%
\widowpenalty=10000
\clubpenalty=10000

%% ========== Set up basic fonts using fontspec ========== %%
% NB: Fontspec will not work with Extensis Suitcase if you store fonts in the Font Vault. 
% You need to have fonts installed on local filesystem or Fontspec will complain about missing tfm files. 
\defaultfontfeatures{Mapping=tex-text}
%\setmainfont[]{Garamond Premier Pro}
%\setsansfont[Scale=MatchLowercase]{Myriad Pro}
%\setmonofont[Scale=MatchLowercase]{Letter Gothic Std}
%\newfontfamily\semibfsf[Scale=MatchLowercase]{Myriad Pro Semibold}
%\newfontfamily\sesffamily[Scale=MatchLowercase]{MyriadPro-SemiCn}

%% ========== Set up fonts for various parts of document (from paper.cls) =========== %%
%\titlefont{\LARGE\bf\sffamily}
%\authorfont{\Large\sffamily}
%\sectionfont{\Large\semibfsf}
%\subsectionfont{\large\semibfsf}
%\subsubsectionfont{\large\sffamily}
%\subtitlefont{\LARGE\sffamily}
%\captionsetup{labelfont={bf,sf}}

%% =========== Page layout and running heads ======= %%
\setlength{\columnsep}{2.5em}
\setlength{\headsep}{2.2ex}
\setlength{\headheight}{1.5em}
\fancyfoot{} 
\fancyhead[RO,LE]{\addfontfeatures{Numbers=OldStyle}\thepage}
\fancyhead[RE]{\addfontfeatures{Numbers=OldStyle}{\sc journal of transport and land use }{\@jtluvolume}.{\@jtluissue}}
\fancyhead[LO]{\itshape\@shorttitle}

%% =========== Establish some convenient shorthands =============== %%
\newcommand\JTLU{{\itshape Journal of Transport and Land Use}}
\newcommand\cclicense{\href{http://creativecommons.org/licenses/by-nc/3.0}{Creative Commons Attribution -- NonCommercial License 3.0}}

%% =========== Set how things are labeled in captions ============= %%
\renewcommand\tableshortname{Table}
\renewcommand\figureshortname{Figure}
%%%%%%%%%%%%%%%%%%%

\newenvironment{onecolkeywords}{%
  \begin{@twocolumnfalse}\begin{keywords}}{%
  \end{keywords}\end{@twocolumnfalse}}



%% =========== Customize paper.cls formatting of abstract ======== %%
\renewenvironment{abstract}%
{\small\paragraph*{\abstractname:}
\let\endabstract=\smallskip}%
{\par\endabstract}


%% =========== Customize paper.cls formatting of keywords ======== %%
\renewenvironment{keywords}%
{\small\paragraph*{\keywordname:}
\def\endkeywords{\vskip 6ex \par}}%
{\par\endkeywords}

%% =========== Maketitle generates author info items too... ====== %%
%% =========== see paper.cls (base doc class) for info =========== %%
\renewcommand\maketitle{%
  \setcounter{footnote}{0}\par
  \begingroup
    \renewcommand\thefootnote{\alph{footnote}}%
    \def\@makefnmark{\hbox to\z@{$\m@th^{\text{\@thefnmark}}$\hss}}%
    \long\def\@makefntext##1{\parindent 1em\noindent
            \hbox to 1.8em{\hss$\m@th^{\@thefnmark}$}##1}% 
      \newpage
      \global\@topnum\z@
      \@maketitle
     \thispagestyle{firstpage}\@thanks
  \endgroup
  \setcounter{footnote}{0}
  \if@journal
    \typeout{Article: \@shortauthor}
    \setcounter{section}{0}%
    \setcounter{subsection}{0}%
    \setcounter{subsubsection}{0}%
    \setcounter{paragraph}{0}%
    \setcounter{subparagraph}{0}%
    \setcounter{figure}{0}%
    \setcounter{table}{0}%
    \addcontentsline{jou}{titles}{%
      {\sss@font\@shortauthor}\hfill\mbox{}\vskip\normallineskip%
       \ifx\@shorttitle\@empty\@title\else\@shorttitle\fi}
      \if@twoside
        \ifx\@oddrunhead\@empty\ifx\@evenrunhead\@empty
        \@mkboth{\@shortauthor}{\@shorttitle}\else
        \@mkboth{}{\@shortauthor, \@shorttitle}\fi \else
        \@mkboth{\@shortauthor, \@shorttitle}{}\fi
      \else
        \markright{\@shortauthor, \@shorttitle}
      \fi
  \else
    \let\maketitle\relax \let\@maketitle\relax
  \fi
    \gdef\@thanks{}\gdef\@author{}\gdef\@title{}\gdef\@institution{}
    \gdef\@subtitle{}
}

%% =================================================
% Code copied/adapted from abstract.sty to avoid using the whole package, which doesn't accommodate the keywords environment well.
\providecommand{\appendiargdef}[2]{\begingroup
  \toks@\expandafter{#1{##1}#2}%
  \edef\@jtlux{\endgroup \def\noexpand#1####1{\the\toks@}}%
  \@jtlux}
\appendiargdef{\thanks}{%
  \protected@xdef\@jtlu@thanks{\@jtlu@thanks
    \protect\footnotetext[\the\c@footnote]{#1}}%
}
\let\@jtlu@thanks\@empty
\newcommand{\saythanks}{\begingroup
  \renewcommand{\thefootnote}{\alph{footnote}}\@jtlu@thanks
  \endgroup\global\let\@jtlu@thanks\@empty}
% \newcommand{\@frontmatter}[1]{\protect\twocolumn[\begin{@twocolumnfalse}#1\end{@twocolumnfalse}]}
% \newenvironment{frontmatter}
%   {\@frontmatter{}{}}





%% =========== Footnote marks ====== %%
% We can use proper superscripts in Garamond rather than faking with LaTeX math mode (default)
\renewcommand\thefootnote{\arabic{footnote}}%
\def\@makefnmark{\hbox{\textsuperscript{\@thefnmark}}}

%% ============ Numbering: sections and subsections only ========== %%
\setcounter{secnumdepth}{2}

%% ========== Print URLs in regular (roman) type ========= %%
\urlstyle{rm}

%% ========== Set up the siunitx package: formatting of numbers and units ====== %%
\sisetup{per-mode=symbol,bracket-unit-denominator=false,detect-all,range-phrase=--}

%% ========== Set up bibliography and reference formatting for natbib === %%
%\bibpunct{[}{]}{,}{n}{}{,} % Format of in-text citations
\bibpunct{(}{)}{;}{a}{}{,} % Format of in-text citations
\setlength{\bibsep}{0pt} % Don't add space between ref list entries

%% ========== Accommodate tables converted by Writer2LaTeX === %%
\newcommand\arraybslash{\let\\\@arraycr} 

%% ========== Easier decimal column definition ========== %%
% NOTE: Deprecated; use the "S" column type from siunitx.sty
\newcolumntype{d}[1]{D{.}{.}{#1}}

%% ========== Float placement, number of floats on page, etc. ============= %%
\renewcommand{\topfraction}{0.9}	% max fraction of floats at top
\renewcommand{\bottomfraction}{0.8}	% max fraction of floats at bottom
% Parameters for TEXT pages (not float pages):
\setcounter{topnumber}{2}
\setcounter{dbltopnumber}{2}
\setcounter{bottomnumber}{2}
\setcounter{totalnumber}{4}     % 2 may work better
\renewcommand{\textfraction}{0.1}	% allow minimal text w. figs
% Parameters for FLOAT pages (not text pages):
\renewcommand{\floatpagefraction}{0.8}	% require fuller float pages

