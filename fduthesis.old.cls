\NeedsTeXFormat{LaTeX2e}
\RequirePackage{expl3,xparse,l3keys2e}
\ProvidesExplClass{fduthesis}
  {2017/02/19}
  {0.2}
  {Fudan University Thesis Template}


%%%%%%%%%% 版本历史 %%%%%%%%%%
% v0.1 2017/02/15
%   开始
% v0.2 2017/02/19
%   git 管理


%%%%%%%%%% 全局变量声明 %%%%%%%%%%
% 保存 fduthesis -> book 的选项列表
\clist_new:N \g__fdu_book_options_clist
% 保存 fduthesis -> geometry 的选项列表
\clist_new:N \g__fdu_geometry_options_clist

% 是否开启双页模式（默认打开）
\bool_new:N \g__fdu_twoside_bool
\bool_set_true:N \g__fdu_twoside_bool


%%%%%%%%%% 文档类选项 %%%%%%%%%%
\keys_define:nn { fdu / option }
  {
    % 页面模式
    oneside .value_forbidden:n = true,
    twoside .value_forbidden:n = true,
    oneside .code:n = {
      \clist_gput_right:Nn \g__fdu_book_options_clist { oneside }
      \bool_set_false:N    \g__fdu_twoside_bool
    },
    twoside .code:n = {
      \clist_gput_right:Nn \g__fdu_book_options_clist { twoside }
      \bool_set_true:N     \g__fdu_twoside_bool
    },
    % 草稿模式
    draft .choice:,
    draft / true  .code:n = {
      \bool_set_true:N     \g__fdu_draft_bool
      \clist_gput_right:Nn \g__fdu_book_options_clist { draft }
    },
    draft / false .code:n = {
      \bool_set_false:N    \g__fdu_draft_bool
    },
    draft .default:n = true,
    draft .initial:n = false
  }

% 处理选项（使用 `l3keys2e' 宏包）
\ProcessKeysOptions { fdu / option }


%%%%%%%%%% 载入标准文档类 %%%%%%%%%%
\PassOptionsToClass { \g__fdu_book_options_clist } { book }
\LoadClass { book }


%%%%%%%%%% 版式设置 %%%%%%%%%%
\RequirePackage { geometry }
\geometry
  {
    % 纸张大小
    paper      = a4paper,
    % 页边距
    left       = 2.54 cm,
    right      = 2.54 cm,
    top        = 3.18 cm,
    bottom     = 3.18 cm,
    % 页眉高度
    headheight = 15 pt
  }
% 草稿模式
\bool_if:NT \g__fdu_draft_bool
  {
    \geometry { showframe }
  }


%%%%%%%%%% 页眉页脚 %%%%%%%%%%
\RequirePackage { fancyhdr }
% 清除所有页面格式
\fancyhf { }
% 页眉(见 `ctex' 下的重定义)
\bool_if:NTF \g__fdu_twoside_bool
  {
    \fancyhead [ EL ]
      { \small \nouppercase { \CJKfamily { kai } \leftmark  } }
    \fancyhead [ OR ]
      { \small \nouppercase { \CJKfamily { kai } \rightmark } }
  }
  {
    \fancyhead [ L ]
      { \small \nouppercase { \CJKfamily { kai } \leftmark  } }
    \fancyhead [ R ]
      { \small \nouppercase { \CJKfamily { kai } \rightmark } }
  }
% 页脚（页码）
\fancyfoot [ C ] { \thepage }
% 关闭横线显示
% \RenewDocumentCommand \headrulewidth { } { 0 pt }
% 完全清除偶数页面
% 见 http://tex.stackexchange.com/q/1681
\RenewDocumentCommand \cleardoublepage { }
  {
    \clearpage
    \bool_if:NT \g__fdu_twoside_bool
      {
        \int_if_odd:nF \c@page
          { \hbox:n { } \thispagestyle { empty } \newpage }
      }
  }


%%%%%%%%%% 西文字体、数学字体 %%%%%%%%%%
\RequirePackage [ no-math ] { fontspec }
\RequirePackage { unicode-math }
\unimathsetup { math-style = ISO, bold-style = ISO }

% 西文字体设置
\keys_define:nn { fdu / style }
  {
    font .choice:,
    font .value_required:n = true,
    font / libertinus .code:n = {
      \setmainfont { Libertinus~Serif }
      \setsansfont { Libertinus~Sans  }
      \setmonofont { TeX~Gyre~Cursor  } [ Ligatures = NoCommon ]
      \setmathfont { Libertinus~Math  }
    },
    font / lm .code:n = {
      \setmainfont { Latin~Modern~Roman }
      \setsansfont { Latin~Modern~Sans  }
      \setmonofont { Latin~Modern~Mono  }
      \setmathfont { Latin~Modern~Math  }
    },
    font / palatino .code:n = {
      \setmainfont { TeX~Gyre~Pagella      }
      \setsansfont { TeX~Gyre~Heros        }
      \setmonofont { TeX~Gyre~Cursor       } [ Ligatures = NoCommon ]
      \setmathfont { TeX~Gyre~Pagella~Math }
    },
    font / times .code:n = {
      %TODO: 20170217  XITS 字体没有 small capital
%      \setmainfont { XITS }
      \setmainfont { TeX~Gyre~Termes }
      \setsansfont { TeX~Gyre~Heros  }
      \setmonofont { TeX~Gyre~Cursor } [ Ligatures = NoCommon ]
      \setmathfont { XITS~Math       }
%      \setmathfont { TeX~Gyre~Termes~Math }
    }
  }


%%%%%%%%%% 中文字体、版式 %%%%%%%%%%
\RequirePackage [ UTF8, heading = true, zihao = -4 ] { ctex }
% 章节标题设置
\ctexset
{
  chapter = {
    format     = {
      \huge \normalfont \sffamily \CJKfamily { hei } \centering
    },
    beforeskip = { 30 pt },
    afterskip  = { 20 pt },
    number     = { \arabic{ chapter } }
  },
  section = {
    format     = { \Large \bfseries \raggedright }
  },
  subsection = {
    format     = { \large \bfseries \raggedright }
  }
}

% 目录设置
\ctexset
{
  % 目录名称
  contentsname = {目 \quad 录},
  % 目录格式
  chapter    / tocline = {
    \normalfont \sffamily \CJKfamily { hei }
    \CTEXnumberline { #1 }    #2
  },
  subsection / tocline = {
    \CJKfamily{ kai }
    \CTEXnumberline { #1 }    #2
  }
}

% 中文字体设置
%BUG: 20170215  见 https://github.com/CTeX-org/ctex-kit/issues/268
\keys_define:nn { fdu / style }
  {
    CJKfont .choice:,
    CJKfont .value_required:n = true,
    CJKfont / adobe .code:n = {
      \setCJKmainfont{ Adobe~Song~Std~L }
        [
          BoldFont = Adobe~Heiti~Std~R,
          ItalicFont = Adobe~Kaiti~Std~R
        ]
    },
    CJKfont / fandol .code:n = {
      \setCJKmainfont { FandolSong }
        [ ItalicFont = FandolKai ]
      \setCJKfamilyfont { song } { FandolSong }
        [ ItalicFont = FandolKai ]
      \setCJKfamilyfont { hei  } { FandolHei  }
      \setCJKfamilyfont { fang } { FandolFang }
      \setCJKfamilyfont { kai  } { FandolKai  }
    },
    CJKfont / founder .code:n = {
      \setCJKmainfont{ FZShuSong-Z01 }
        [ BoldFont = FZXiaoBiaoSong-B05, ItalicFont = FZKai-Z03 ]
%        [ ItalicFont = 方正楷体_GBK, AutoFakeBold = true ]
%        [ BoldFont = 方正黑体_GBK, ItalicFont = 方正楷体_GBK ]
      \setCJKfamilyfont { song } { FZShuSong-Z01 }
        [ BoldFont = FZXiaoBiaoSong-B05, ItalicFont = FZKai-Z03 ]
      \setCJKfamilyfont { hei  } { FZHei-B01      }
      \setCJKfamilyfont { fang } { FZFangSong-Z02 }
      \setCJKfamilyfont { kai  } { FZKai-Z03      }
    },
%    CJKfont / linux .code:n = {
%      \setCJKmainfont{ SimSun }
%        [ BoldFont = SimHei, ItalicFont = KaiTi ]
%    },
    CJKfont / mac .code:n = {
      \setCJKmainfont{ STSong }
        [ ItalicFont = STKaiti, AutoFakeBold = true ]
      \setCJKfamilyfont { song } { STSong     }
        [ ItalicFont = STKaiti, AutoFakeBold = true ]
      \setCJKfamilyfont { hei  } { STHeiti    }
      \setCJKfamilyfont { fang } { STFangsong }
      \setCJKfamilyfont { kai  } { STKaiti    }
    },
    CJKfont / windows .code:n = {
      \setCJKmainfont{ SimSun }
        [ ItalicFont = KaiTi, AutoFakeBold = true ]
      \setCJKfamilyfont { song } { SimSun   }
        [ ItalicFont = KaiTi, AutoFakeBold = true ]
      \setCJKfamilyfont { hei  } { SimHei   }
      \setCJKfamilyfont { fang } { FangSong }
      \setCJKfamilyfont { kai  } { KaiTi    }
    },
  }

% 半角、全角句号
\keys_define:nn { fdu / style }
  {
    fullwidth-stop .bool_set:N = \l__fdu_info_fullstop_bool,
    fullwidth-stop .default:n = true
  }
% `\addCJKfontfeatures' 要放在 `\begin{document}' 之后
% 钩子使用 `ctexhook' 宏包
\ctex_after_end_preamble:n
  {
    \bool_if:NT \l__fdu_info_fullstop_bool
      { \addCJKfontfeatures { Mapping = fullwidth-stop } }
  }

% 默认字号设置
% 小四号字体由 `ctex' 默认
\keys_define:nn { fdu / style }
  {
    zihao .choice:,
    zihao .value_required:n = true,
    zihao / -4 .code:n = { },
    zihao / 5  .code:n = {
      \RenewDocumentCommand \tiny         { } { \zihao {  7 } }
      \RenewDocumentCommand \scriptsize   { } { \zihao { -6 } }
      \RenewDocumentCommand \footnotesize { } { \zihao {  6 } }
      \RenewDocumentCommand \small        { } { \zihao { -5 } }
      \RenewDocumentCommand \normalsize   { } { \zihao {  5 } }
      \RenewDocumentCommand \large        { } { \zihao { -4 } }
      \RenewDocumentCommand \Large        { } { \zihao { -3 } }
      \RenewDocumentCommand \LARGE        { } { \zihao { -2 } }
      \RenewDocumentCommand \huge         { } { \zihao {  2 } }
      \RenewDocumentCommand \Huge         { } { \zihao {  1 } }
    },
  }

% `fancy' 版式必须在 `ctex' 调用之后
\pagestyle { fancy }
% 重定义右页眉格式
\RenewDocumentCommand \sectionmark { m }
  { \markright { \CTEXthesection \negthinspace \quad #1 } }


%%%%%%%%%% 插图 %%%%%%%%%%
\RequirePackage { graphicx }






%%%%%%%%%% 论文信息 %%%%%%%%%%
\keys_define:nn { fdu / info }
  {
    title        .tl_set:N    = \l__fdu_info_title_tl,
    title*       .tl_set:N    = \l__fdu_info_title_english_tl,
    %
    date         .tl_set:N    = \l__fdu_info_date_tl,
    %
    author       .tl_set:N    = \l__fdu_info_author_tl,
    author*      .tl_set:N    = \l__fdu_info_author_english_tl,
    %
    supervisor   .tl_set:N    = \l__fdu_info_supervisor_tl,
    supervisor*  .tl_set:N    = \l__fdu_info_supervisor_english_tl,
    %
    instructors  .clist_set:N = \l__fdu_info_instructors_clist,
    %
    major        .tl_set:N    = \l__fdu_info_major_tl,
    major*       .tl_set:N    = \l__fdu_info_major_english_tl,
    %
    department   .tl_set:N    = \l__fdu_info_department_tl,
    department*  .tl_set:N    = \l__fdu_info_department_english_tl,
    %
    studentID    .tl_set:N    = \l__fdu_info_student_ID_tl,
    schoolID     .tl_set:N    = \l__fdu_info_school_ID_tl,
    %
    keyword      .clist_set:N = \l__fdu_info_keyword_clist,
    keyword*     .clist_set:N = \l__fdu_info_keyword_english_clist,
    %
    CLC          .tl_set:N    = \l__fdu_info_CLC_tl
  }

%\NewDocumentCommand \printinfo {}
%{
%  \l__fdu_info_title_tl \\
%  \l__fdu_info_title_english_tl \\
%  \l__fdu_info_author_tl \quad \l__fdu_info_author_english_tl
%}


%%%%%%%%%% 封面绘制——内部函数 %%%%%%%%%%

% 分散对齐盒子
% #1=length, #2=content
\cs_new:Npn \fdu_spread_box:Nn #1 #2
 {
  % With \tl_map_inline:nn we insert \hfil between letters;
  % a final \unskip kills the last \hfil
  % 见 http://tex.stackexchange.com/q/169689
  \makebox [ #1 ] [ s ]
    {
      \tl_map_inline:nn { #2 } { ##1 \hfil } \unskip
    }
 }

% 居中对齐盒子
% #1=length, #2=content
\cs_new:Npn \fdu_center_box:Nn #1 #2
  {
    \makebox [ #1 ] [ c ] { #2 }
  }

% 设置 dim 变量文本宽度
% #1=dim变量，#2= content
\box_new:N \l__fdu_temp_box
\cs_new:Npn \fdu_set_text_width:Nn #1 #2
  {
    \hbox_set:Nn \l__fdu_temp_box { #2 }
    \dim_set:Nn #1
      { \box_wd:N \l__fdu_temp_box }
  }

% 信息栏左右宽度
\dim_new:N \l__fdu_cover_info_L_dim
\dim_new:N \l__fdu_cover_info_R_dim

\dim_new:N \l__fdu_cover_info_temp_dim


%%%%%%%%%% 封面绘制——构建 %%%%%%%%%%
\NewDocumentCommand \makecover { }
  {
    \begin{titlepage}
      \begin{flushright}
        \setlength { \rightskip } { -2 em }
        \parbox [ c ] { 10 em }
          {
            \small
            学校代码    ： \l__fdu_info_school_ID_tl  \par
            学 \qquad 号： \l__fdu_info_student_ID_tl
          }
      \end{flushright}
      
      \vfill

      \begin{figure} [ h ]
        \centering
        \includegraphics [width = 0.5 \textwidth]
          { Fudan_LOGO.pdf }
      \end{figure}
      
      \vfill
      
      \begin{center}
        \fdu_spread_box:Nn { 0.45 \textwidth }
          { \Huge 本科毕业论文 }
        \par
        
        \vspace { \stretch{ 3 } }

        % 中文标题
        { \huge \sffamily \CJKfamily { hei }  \l__fdu_info_title_tl }
        \par
        
        \vfill
        
        % 西文标题
        { \Large \l__fdu_info_title_english_tl }
        \par
        
        \vspace { \stretch{ 4 } }
        
        % 院系、姓名等
        
        % 设置左边宽度
        \dim_set:Nn \l__fdu_cover_info_L_dim { 6 em }

        % 设置右边宽度
        % 实现方法概要：将字段宽度存入 `\l__fdu_cover_info_temp_dim'
        % 变量，比较并将最长的宽度作为 `\l__fdu_cover_info_R_dim'
        % 使用。
        % TODO: 20170220  需要采用更简单的方法

        % Compare with `department'
%        \dim_show:N \l__fdu_cover_info_R_dim
        \fdu_set_text_width:Nn \l__fdu_cover_info_temp_dim
          { \large \l__fdu_info_department_tl }
        \dim_set:Nn \l__fdu_cover_info_R_dim
          {
            \dim_max:nn
              \l__fdu_cover_info_R_dim \l__fdu_cover_info_temp_dim
          }
        % Compare with `major'
%        \dim_show:N \l__fdu_cover_info_R_dim
        \fdu_set_text_width:Nn \l__fdu_cover_info_temp_dim
          { \large \l__fdu_info_major_tl }
        \dim_set:Nn \l__fdu_cover_info_R_dim
          {
            \dim_max:nn
              \l__fdu_cover_info_R_dim \l__fdu_cover_info_temp_dim
          }
        % Compare with `author'
%        \dim_show:N \l__fdu_cover_info_R_dim
        \fdu_set_text_width:Nn \l__fdu_cover_info_temp_dim
          { \large \l__fdu_info_author_tl }
        \dim_set:Nn \l__fdu_cover_info_R_dim
          {
            \dim_max:nn
              \l__fdu_cover_info_R_dim \l__fdu_cover_info_temp_dim
          }
        % Compare with `supervisor'
%        \dim_show:N \l__fdu_cover_info_R_dim
        \fdu_set_text_width:Nn \l__fdu_cover_info_temp_dim
          { \large \l__fdu_info_supervisor_tl }
        \dim_set:Nn \l__fdu_cover_info_R_dim
          {
            \dim_max:nn
              \l__fdu_cover_info_R_dim \l__fdu_cover_info_temp_dim
          }
        % Compare with `date'
%        \dim_show:N \l__fdu_cover_info_R_dim
        \fdu_set_text_width:Nn \l__fdu_cover_info_temp_dim
          { \large \l__fdu_info_date_tl }
        \dim_set:Nn \l__fdu_cover_info_R_dim
          {
            \dim_max:nn
              \l__fdu_cover_info_R_dim \l__fdu_cover_info_temp_dim
          }
%        \dim_show:N \l__fdu_cover_info_R_dim
%        \dim_add:Nn \l__fdu_cover_info_R_dim { 2 em }

        % 构建信息栏
        \parbox [ c ] { \textwidth }
        {
          \centering \large

          \fdu_spread_box:Nn \l__fdu_cover_info_L_dim
            { 院系 } ：
          \fdu_center_box:Nn \l__fdu_cover_info_R_dim
            { \l__fdu_info_department_tl }
          \par
          
          \fdu_spread_box:Nn \l__fdu_cover_info_L_dim
            { 专业 } ：
          \fdu_center_box:Nn \l__fdu_cover_info_R_dim
            { \l__fdu_info_major_tl }
          \par
          
          \fdu_spread_box:Nn \l__fdu_cover_info_L_dim
            { 姓名 } ：
          \fdu_center_box:Nn \l__fdu_cover_info_R_dim
            { \l__fdu_info_author_tl }
          \par
          
          \fdu_spread_box:Nn \l__fdu_cover_info_L_dim
            { 指导教师 } ：
          \fdu_center_box:Nn \l__fdu_cover_info_R_dim
            { \l__fdu_info_supervisor_tl }
          \par
          
          \fdu_spread_box:Nn \l__fdu_cover_info_L_dim
            { 完成日期 } ：
          \fdu_center_box:Nn \l__fdu_cover_info_R_dim
            { \l__fdu_info_date_tl }
        }
      \end{center}
      
      \vfill

      \newpage

      \thispagestyle { empty }
      \vspace* { 30 pt }
      \begin{center}
        \huge \normalfont \sffamily \CJKfamily { hei }
        \fdu_spread_box:Nn { 7 em }
          { 指导小组成员 }
      \end{center}
      \vspace { 20 pt }

      \begin{center}
        \large
        \clist_use:Nn \l__fdu_info_instructors_clist { \par }
      \end{center}
    \end{titlepage}
    
    \tableofcontents
  }


%%%%%%%%%% 摘要 %%%%%%%%%%
% 中文摘要
\NewDocumentEnvironment { abstract } { }
  {
    \chapter*{摘 \quad 要}
    \addcontentsline{toc}{chapter}
      {\normalfont \sffamily \CJKfamily {hei} 摘 \quad 要}
%    \thispagestyle { plain }
%    \vspace* { 10 pt }
%    \begin{center}
%      \Large \normalfont \sffamily \CJKfamily { hei }
%      摘 \quad 要
%    \end{center}
%    \vspace { 10 pt }
%    \par
  }
  {
    \par
    \mbox{}
    \par
    
    \noindent \hangindent = 4 em \hangafter = 1
    { \normalfont \sffamily \CJKfamily { hei } 关键字： }
    \clist_use:Nn \l__fdu_info_keyword_clist { ； }
    \par
    
    \noindent
    { \normalfont \sffamily \CJKfamily { hei } 中图分类号： }
    \l__fdu_info_CLC_tl
%    \par
    
%    \cleardoublepage
  }

% 英文摘要
\NewDocumentEnvironment { abstract* } { }
  {
    \chapter*{Abstract}
    \addcontentsline{toc}{chapter}
      {\normalfont \sffamily \CJKfamily {hei} Abstract}
%    \thispagestyle { plain }
%    \vspace* { 10 pt }
%    \begin{center}
%      \Large \normalfont \sffamily \CJKfamily { hei } 
%      Abstract
%    \end{center}
%    \vspace { 10 pt }
%    \par
  }
  {
    \par
    \mbox{}
    \par
    
    \noindent \hangindent = 4 em \hangafter = 1
    \textbf{Keywords:} \quad
    \clist_use:Nn \l__fdu_info_keyword_english_clist { \quad }
    \par
    
    \noindent
    \textbf{CLC~ number:} \quad
    \l__fdu_info_CLC_tl
%    \par
    
%    \cleardoublepage
  }


%%%%%%%%%% 键值设置 %%%%%%%%%%
% meta 键值对
\keys_define:nn { fdu }
  {
    info  .meta:nn = { fdu / info  } { #1 },
    style .meta:nn = { fdu / style } { #1 }
  }

% fdusetup 函数
\NewDocumentCommand \fdusetup { m }
  { \keys_set:nn { fdu } { #1 } }

% 初始设置
\keys_set:nn { fdu }
  {
    style/font = times,
    style/CJKfont = fandol,
    style/fullwidth-stop = false,
    style/zihao = -4,
%    draft = false
    info/date = \today
  }