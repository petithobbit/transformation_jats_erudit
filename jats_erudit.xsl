<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns="http://www.erudit.org/xsd/article">
    <xsl:output method="xml" indent="yes" encoding="iso-8859-1"/>

    <!-- IB 2016-10-30 réécriture complète du script avec templates -->

    <xsl:template match="/">
        <article xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.erudit.org/xsd/article http://www.erudit.org/xsd/article/3.0.0/eruditarticle.xsd"
            qualtraitement="complet" idproprio="{//article-id[@pub-id-type='publisher-id']}"
            typeart="autre" lang="fr" ordseq="1">
            <xsl:apply-templates/>
        </article>

    </xsl:template>


    <!-- =================================== Élément structurants ==================================== -->

    <!-- admin et liminaire-->
    <xsl:template match="front">
        <admin>
            <xsl:apply-templates select="article-meta"/>
            <xsl:apply-templates select="journal-meta"/>
        </admin>
        <liminaire>
            <xsl:apply-templates select="article-meta/title-group"/>
            <grauteur>
                <xsl:apply-templates
                    select="article-meta/contrib-group/contrib[@contrib-type='author']"/>
            </grauteur>
            <resume lang="fr">
                <xsl:apply-templates
                    select="article-meta/abstract[@abstract-type='executive-summary']"/>
            </resume>
            <grmotcle lang="fr">
                <xsl:apply-templates
                    select="article-meta/kwd-group[@kwd-group-type='author-keywords']"/>
            </grmotcle>
        </liminaire>
        <xsl:apply-templates select="body"/>
    </xsl:template>

    <!-- =========================== développement des unités d'information =========================== -->
    <!-- =================================== approche ascendante ====================================== -->

    <!-- ..............................article-meta : infoarticle...................................... -->

    <xsl:template match="article-meta">
        <infoarticle>
            <idpublic scheme="doi">
                <xsl:value-of select="article-id[@pub-id-type='doi']"/>
            </idpublic>
            <grdescripteur lang="fr" scheme="http://rameau.bnf.fr">
                <xsl:for-each select="article-categories/subj-group[@subj-group-type='heading']">
                    <descripteur>
                        <xsl:value-of select="current()"/>
                    </descripteur>
                </xsl:for-each>
            </grdescripteur>
            <nbpara>
                <xsl:value-of select="count(//p)"/>
            </nbpara>
            <!-- @todo : voir si le calcul se fait dans Stylo -->
            <nbmot/>
            <nbfig>
                <xsl:value-of select="count(//fig)"/>
            </nbfig>
            <nbtabl>
                <xsl:value-of select="count(//table)"/>
            </nbtabl>
            <!-- @todo : vérifier sémantique des diverses balises utilisées pour fig/image et audio/video -->
            <nbimage/>
            <nbaudio/>
            <nbvideo/>
            <!-- @todo : count(//ref[@id]) pas assez précis pour (<ref id="bib59">) ajouter regex si possible -->
            <nbrefbiblio>
                <xsl:value-of select="count(//ref[@id])"/>
            </nbrefbiblio>
            <nbnote/>
        </infoarticle>
    </xsl:template>

    <!-- ....................................journal-meta : revue.......................................... -->

    <xsl:template match="journal-meta">
        <revue id="sp01868" lang="fr">
            <!-- traitement des titres -->
            <xsl:apply-templates select="journal-title-group"/>
            <!-- @todo : valider si issnnum est el obligatoire sur les instances créées par Stylo-->
            <idissnnum>
                <xsl:value-of select="issn[@publication-format='electronic']"/>
            </idissnnum>
            <!-- teste si contributeurs présents -->
            <xsl:if test="./contrib-group/contrib">
                <xsl:apply-templates select="./contrib-group"/>
            </xsl:if>
        </revue>

        <!-- ............article-meta : liste de petites unités d'info non regroupées sous <admin>.............. -->

        <!-- @todo : att id de balise num: où aller puiser cette information? tenez-vous un catalogue?
                        sinon, article-meta/@issue-id, mais non présent sur les artéfacts-->
        <numero id="lorem-ipsum">
            <xsl:apply-templates select="../article-meta/pub-date[@date-type='pub']"/>
            <grtheme>
                <!-- @todo : trouver quel élément correspond au thèmes du no dans extrant Stylo. article-meta vs
                contrib?-->
                <theme>lorem ipsum</theme>
            </grtheme>
        </numero>
        <!--  IB 2016-10-20 : Les balises editeur, prodnum et diffnum devraient normalement être balisées
                    par l'élément <role> de contrib, dans contrib-group. Comme le type de contribution
                y est défini par une valeur d'attribut de contrib-type, il est impossible de savoir
                en ce moment comment extraire l'info, avec les artéfacts fournis.
                On remarque ici qu'il apparait nécessaire de normaliser ces valeurs d'attribut en amont afin de pouvoir
                transformer l'extrant de Stylo de façon satisfaisante.
                -->
        <editeur>
            <nomorg/>
        </editeur>
        <prod>
            <nomorg/>
        </prod>
        <prodnum>
            <nomorg/>
        </prodnum>
        <diffnum>
            <nomorg/>
        </diffnum>
        <!-- IB: 2016-10-20 : el histpapier est facultatif selon schéma 3.0.0. je laisse ici le boilerplate
                    retrouvé sur les 2 artéfacts tout de même, Re: conversation avec Arthur.-->
        <histpapier>
            <alinea>lorem ipsum</alinea>
        </histpapier>
        <!-- élément schéma est du boilerplate ici -->
        <schema nom="Erudit Article" version="3.0.0" lang="fr"/>
        <droitsauteur>
            <!-- /article/front[1]/article-meta[1]/permissions[1] -->
            <xsl:apply-templates select="../article-meta/permissions"/>
        </droitsauteur>
    </xsl:template>
    
    <!-- ................................. corps .............................................-->
    <xsl:template match="article/body">
        <corps>
            <xsl:apply-templates/>
        </corps>
        <xsl:apply-templates select="article/back"/>
    </xsl:template>
    
    <!-- ..............................parties annotées ..........................-->
    <xsl:template match="article/back">
        
        <partieann>
            <xsl:apply-templates select="ref-list"/>
            <!-- @todo : groupe notes- besoin de plus d'info avant de continuer -->
           <grnotes>
               <note>
                   <no/>
                   <alinea></alinea>
               </note>
           </grnotes>
        </partieann>
        
    </xsl:template>
    <!-- .............................. parties retirées (subarticles) ..............-->
  
    <!-- +++++++++++++++++++++++++++++++++++++++++++++++ templates +++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    <xsl:template match="sub-article"/>
    <xsl:template match="ack"/>
    <xsl:template match="sec"/>
    
   
    <!-- ................................ sous-éléments ..............................-->
<!-- sections -->
    <xsl:template match="article/body/sec">
        <section1>
            <xsl:apply-templates/>
        </section1>
    </xsl:template>
    <xsl:template match="article/body/sec/sec">
        <section2>
            <xsl:apply-templates/>
        </section2>
    </xsl:template>
    <xsl:template match="article/body/sec/sec/sec">
        <section3>
            <xsl:apply-templates/>
        </section3>
    </xsl:template>
    
    <!-- titres -->
    <xsl:template match="journal-title-group">
        <titrerev>
            <!-- journal-title : contenu mixte -->
            <xsl:apply-templates select="journal-title"/>
        </titrerev>
        <xsl:if test="abbrev-journal-title"/>
        <titrerevabr>
            <xsl:apply-templates select="abbrev-journal-title"/>
        </titrerevabr>
    </xsl:template>

    <xsl:template match="article-meta/title-group">
        <grtitre>
            <!-- article-title : contenu mixte -->
            <titre>
                <xsl:apply-templates select="article-title"/>
            </titre>
        </grtitre>
        <!-- @todo : traitement des sous-titres  -->
    </xsl:template>
    <xsl:template match="sec/title">
        <titre>
            <xsl:apply-templates/>
        </titre>
    </xsl:template>

    <!-- contributeurs (editeur, rédacteur, auteurs etc.) -->
    <!-- directeur -->

    <xsl:template match="contrib-group">
        <!-- @todo : isoler les <contrib> enfants de <journal-meta> dans Xpath-->
        <xsl:for-each select="contrib[@contrib-type='editor']">
            <!-- directeur (optionnel et répétable ad infini) : 
                 att "sexe"  non traduite : aucune donnée dans texte source et el facultatif dans texte arrivée.
                 Normalement, les collaborateurs de la revue devraient être situés sous <journal-meta>, et non
                    <article-meta>. Balises créées dans artéfact pour tester. 
                 @todo : Valider à quel endroit de l'arborescence seront logés les informations sur le directeur et
                    le rédacteur dans les extrants créés par Stylo.
                 @todo : trouver valeur de l'attribut "contrib-type" utilisé par style pour désigner les titres 
                 dans la balise "contrib". ici je prend la valeur "editor" et "guest-editor" pour pouvoir tester le script-->
            <directeur>
                <xsl:apply-templates/>
            </directeur>
        </xsl:for-each>

        <!-- rédacteur en chef invité -->
        <xsl:for-each select="contrib[@contrib-type='guest-editor']">
            <!-- redacteur en chef (optionnel et répétable ad infini) :  
                        1) att "sexe"  non traduite : aucune donnée dans texte source et el facultatif dans texte arrivée
                        2) je dois savoir quelle valeur de l'attribut "contrib-type" est utilisé par style pour désigner le titre de
                         directeur dans la balise "contrib". ici je prend la valeur inventée "guest-editor" pour pouvoir tester le script
                        3) att lang non présente dans les artéfacts, mais
                        4) att idref non presente dans les artéfacts -->
            <redacteurchef typerc="invite">
                <!--fonction : att lang "fr" mise ar défaut-->
                <fonction lang="fr">
                    <xsl:value-of select="./role"/>
                </fonction>
                <xsl:apply-templates select="name"/>
            </redacteurchef>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="article-meta/contrib-group/contrib[@contrib-type='author']">
        <xsl:for-each select=".">
            <auteur id="{./@id}">
                <xsl:apply-templates/>
            </auteur>
        </xsl:for-each>

    </xsl:template>
    <!-- désactive <role> et <aff> par défaut dans <contrib>
        <xref> dans contrib désactivé ici aussi @todo : vérifier si on les garde.
        @todo : enlever espaces blancs dans l'extrant xslt au besoin-->
    <xsl:template match="role"/>
    <xsl:template match="aff"/>
    <xsl:template match="contrib/xref"/>

    <!-- noms -->
    <xsl:template match="name">
        <nompers>
            <prenom>
                <xsl:value-of select="given-names"/>
            </prenom>
            <nomfamille>
                <xsl:value-of select="surname"/>
            </nomfamille>
        </nompers>
    </xsl:template>
    <xsl:template match="person-group/name"/>

    <!-- dates de publication -->
    <xsl:template match="pub-date[@date-type='pub']">
        <pub>
            <annee>
                <xsl:value-of select="./year"/>
            </annee>
        </pub>
        <pubnum>
            <date>
                <xsl:value-of select=".[@publication-format='electronic']/year"/>-<xsl:value-of
                    select=".[@publication-format='electronic']/month"/>-<xsl:value-of
                    select=".[@publication-format='electronic']/day"/>
            </date>
        </pubnum>
    </xsl:template>

    <!-- droitsauteur -->
    <!-- @todo : valider quelle séquence de balises est utilisée ici par stylo pour pouvoir modéliser autrement que par pulls  -->
    <xsl:template match="permissions">
        <xsl:value-of select="license/license-p"/>
        <nomorg>
            <xsl:value-of select="copyright-holder"/>
        </nomorg>, <xsl:value-of select="copyright-year"/>
    </xsl:template>

    <!-- resume : sélection volontaire d'un des deux types d'abstracts présentés dans les artéfacts 
        @todo : voir s'il faut mettre en place un "catch" pour empêcher l'affichage du dernier <p> qui, 
   dans les artéfacts fournis, montrent un doi et non du texte
        @todo : valider quel abstract on conserve pour la version erudit-->
    
    <xsl:template match="//article-meta/abstract[@abstract-type='executive-summary']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- resume: traitement particulier des deux premières balises de <abstract> -->
    <xsl:template match="object-id"/>
    <xsl:template match="abstract/title"/> 
    
    <!-- grmotcle
        ceux-ci sont choisis par l'auteur-->
    <xsl:template match="article-meta/kwd-group[@kwd-group-type='author-keywords']">
       <xsl:for-each select="./kwd"> 
            <motcle>
                <xsl:value-of select="."/>
            </motcle>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- ...................................... contenus mixtes ........................................ -->
    

    <!-- titres -->
    <xsl:template match="journal-title | abbrev-journal-title | article-title">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- para -->
    <xsl:template match="p">
        <para>
            <!-- @todo voir si jats a l'équivalent de l'alinea -->
            <alinea>
                <xsl:apply-templates/>
            </alinea>
        </para>
    </xsl:template>
    
    <!-- éléments p de jats qui ne prennent pas de para dans érudit -->
    <xsl:template match="abstract/p | list-item/p | disp-quote/p |fn/p">
        <alinea>
            <xsl:apply-templates/>
        </alinea>
    </xsl:template>
    
    <!--liste-->
    <!-- @todo traiter les listes dans body front abstract etc. voir doc -->
    <xsl:template match="list">
        <xsl:choose>
            <xsl:when test="parent::sec">
                <para>
                    <xsl:call-template name="listes"/>
                </para>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="listes"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- exemple de regle nommee -->
    <xsl:template name="listes">
        <xsl:param name="content"/>
        <xsl:choose>
            <xsl:when test="@list-type='order'">
                <listeord numeration="decimal">
                    <xsl:apply-templates/>
                </listeord>
            </xsl:when>
            <xsl:otherwise>
                <!-- default pour @list-type="bullet" -->
                <listenonord signe="disque">
                    <xsl:apply-templates/>
                </listenonord>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- renvois : création des types (attributs et valeurs d'attribut) -->
    <xsl:template match="xref">
        <xsl:element name="renvoi">
            <xsl:if test="@rid">
                <xsl:attribute name="idref">
                    <xsl:value-of select="."/>
                </xsl:attribute>      
            </xsl:if>
            <xsl:if test="@ref-type">
                <xsl:if test="@ref-type['author-note']">
                    <xsl:attribute name="typeref">note</xsl:attribute>
                </xsl:if>
                <xsl:if test="@ref-type['bibr']">
                    <xsl:attribute name="typeref">refbiblio</xsl:attribute>
                </xsl:if>
            </xsl:if>  
        </xsl:element>
    </xsl:template>
    
    <!-- figures
    les objets d'information de type figure d"érudit sont un sous-groupe d'une balise
    plus générique dans jats
    image id : <xsl:value-of select="./graphic/@xlink:href" xpath-default-namespace="http://www.w3.org/1999/xlink"></xsl:value-of>-->
    
    <xsl:template match="fig/object-id">
        <figure>
            <objetmedia flot="bloc">
                <xsl:element name="image">
                    <xsl:attribute name="typeimage">figure</xsl:attribute>
                    <xsl:attribute name="desc">lorem-ipsum</xsl:attribute>
                    <xsl:attribute name="id">url-relatif</xsl:attribute>
                    <!-- @todo namespace pour xlink -->
                    <xsl:attribute name="xlinktype">simple</xsl:attribute>
                </xsl:element> 
            </objetmedia>
        </figure>
    </xsl:template>
    
    <!-- bloc citation
    @todo : le traitement des citations se fait à l'intérieur des paragraphes dans JATS
    et à l'extérieur des paragraphes dans érudit. le traitement proposé ici n'est pas valide
    selon le schéma 3.0.0.-->
    <xsl:template match="disp-quote">
        <bloccitation>
                <xsl:apply-templates/>
        </bloccitation>
    </xsl:template>
    
<!-- groupe note 
    @todo : besoin d'artéfacts qui montrent l'utilisation des notes en jats.
    Aussi, valider comment les références sont générées-->
    <!--<xsl:template match="fn">
        <xsl:element name="note">
            <xsl:attribute name="id">
                <xsl:value-of select="./@id"/>
            </xsl:attribute>
        </xsl:element>
        <xsl:apply-templates/>
    </xsl:template>-->
    
    <xsl:template match="ref-list">
        <grbiblio>
            <biblio>
                <xsl:apply-templates/>
            </biblio>
        </grbiblio>
    </xsl:template>
    
    <xsl:template match="ref">
        <refbiblio>
            <xsl:for-each select="element-citation/person-group/name">
                <xsl:value-of select="surname/text()"/>, <xsl:value-of select="given-names/text()"/>.
            </xsl:for-each>
            <marquage typemarq="italique">
            <xsl:value-of select="element-citation/article-title"/>
            </marquage>,
            <xsl:if test="element-citation/source">
                <xsl:value-of select="element-citation/source"/>
            </xsl:if>
            <xsl:if test="volume">
                vol. <xsl:value-of select="element-citation/volume"/>
            </xsl:if>
            <xsl:if test="element-citation/fpage">
                p. <xsl:value-of select="element-citation/fpage"></xsl:value-of>
            </xsl:if>
            <xsl:if test="element-citation/lpage">
                -<xsl:value-of select="element-citation/lpage"/>.
            </xsl:if>
            <xsl:if test="element-citation/ext-link">
               <xsl:apply-templates/>
            </xsl:if>
        </refbiblio>
    </xsl:template>
     
     <!-- liens externes -->
    <xsl:template match=" ext-link">
        <xsl:element name="liensimple">
            <!-- @todo namespace xlink -->
            <xsl:attribute name="xlinktype">simple</xsl:attribute>
            <xsl:attribute name="xlinkhref">url/doi</xsl:attribute>
        </xsl:element>
        <!-- @todo valeur de <liensimple> doit être modifiée pour url de l'attribut RE: namespaces -->
        <xsl:value-of select="."/>
    </xsl:template>
    
    
    
    <!-- italique -->
    <xsl:template match="italic">
        <xsl:element name="marquage" namespace="http://www.erudit.org/xsd/article">
            <xsl:attribute name="typemarq">italique</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
