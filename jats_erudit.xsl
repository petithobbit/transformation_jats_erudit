<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xpath-default-namespace="http://jats.nlm.nih.gov"
    xmlns="http://www.erudit.org/xsd/article">
    <xsl:output method="xml" indent="yes" encoding="iso-8859-1"/>


    <!-- IB 2016-10-24 : Période de travail avec E Chateau, ajout namespaces et el structurants corps-->
    <!-- IB 2016-10-19 : Preuve de concept. Prototype script pour validation Version 1.0
            Stratégie utilisée pour le script: 
            Réécriture complète de l'article en suivant l'arborescence du Schéma Érudit.
            Éléments structurants (complexes sans PCDATA) directement écrits dans le XSLT.
            Traitement du balisage orienté présentation fait par l'utilisation de templates.
            
            Rationale : Le script sera alors extensible. ET valide.
            Désavantage : beaucoup de boilerplate. À revoir à chaque nouvelle version du schéma Érudit.
            Avantage : rapide dans un contexte de preuve de concept (2 semaines pour produire le script).
            -->

    <!--  IB 2016-10-19 : Sur les 2 artéfacts analysés :
                attribut qualtraitement: valeur "complet" par défaut 
                attribut idproprio: valeur tirée de l'instance xml
                attribut typeart: valeur "autre" par défaut 
                attribut lang: valeur "fr" par défaut (comme présence de tag abuse et puisque la balise corr est optionnelle)
                attribut ordseq: valeur "1" par défaut (je ne sais pas trop quoi faire avec cette information)
                
                Ensemble de la balise "article" considéré largement comme boilerplate.
                Valider si le corpus analysé représente suffisamment les scénarios possibles.
                
                version ultérieure demandera plusieurs artéfact en provenance de Stylo
           -->

    <xsl:template match="/">
        <!-- idproprio : il faut valider avec Érudit pour avoir la signification exacte de l'identifiant 
            et ainsi voir si la traduction est exacte  -->

        <article xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           
            xsi:schemaLocation="http://www.erudit.org/xsd/article http://www.erudit.org/xsd/article/3.0.0/eruditarticle.xsd"
            qualtraitement="complet" idproprio="{//article-id[@pub-id-type='publisher-id']}"
            typeart="autre" lang="fr" ordseq="1">

            <!-- ========================= el structurant admin (OBL) ==================================-->
<!--
            <admin>
                <infoarticle>
                    <idpublic scheme="">
                        
                    </idpublic>
                </infoarticle>
            </admin> -->
            
            <xsl:element name="admin" namespace="http://www.erudit.org/xsd/article">
                <xsl:element name="infoarticle" namespace="http://www.erudit.org/xsd/article">
                    <!--IB 2016-10-19 : attribut "scheme" #required, donc considéré comme boilerplate -->
                    <xsl:element name="idpublic">
                        <xsl:attribute name="scheme">
                            <xsl:value-of select="'doi'"/>
                        </xsl:attribute>
                        <!--<idpublic scheme="doi">
                        <xsl:value-of select="//article-meta/article-id[@pub-id-type='doi']"/>
                    </idpublic>-->
                    </xsl:element>
                    <grdescripteur lang="fr" scheme="http://rameau.bnf.fr">
                        <xsl:for-each select="//subj-group[@subj-group-type='heading']">
                            <descripteur>
                                <xsl:value-of select="current()"/>
                            </descripteur>
                        </xsl:for-each>
                    </grdescripteur>
                    <!-- IB 2016-10-20 : La majorité des métadonnées ici nécessitent plus d'info sur la façon 
                        de les repêcher dans le texte source, Je suis allé chercher celles qui étaient évidentes. -->
                    <nbpara>
                        <xsl:value-of select="count(//p)"/>
                    </nbpara>
                    <nbmot> </nbmot>
                    <nbfig>
                        <xsl:value-of select="count(//fig)"/>
                    </nbfig>
                    <nbtabl>
                        <xsl:value-of select="count(//table)"/>
                    </nbtabl>
                    <nbimage> </nbimage>
                    <nbaudio> </nbaudio>
                    <nbvideo> </nbvideo>
                    <!-- IB: count(//ref[@id]) pas assez précis pour (<ref id="bib59">) ajouter regex si possible -->
                    <nbrefbiblio>
                        <xsl:value-of select="count(//ref[@id])"/>
                    </nbrefbiblio>
                    <nbnote/>
                </xsl:element>

                <!-- les attributs de "revue": "id" et "lang" sont du boilerplate, pas de correspondances trouvées-->
                <revue id="sp01868" lang="fr">
                    <!-- le titre de revue est un el obligatoire -->
                    <titrerev>
                        <xsl:value-of select="//journal-title-group/journal-title"/>
                    </titrerev>
                    <!-- le titre abrégé de revue est un el facultatif -->
                    <xsl:if test="//journal-title-group/abbrev-journal-title"/>
                    <titrerevabr>
                        <xsl:value-of select="//journal-title-group/abbrev-journal-title"/>
                    </titrerevabr>
                    <!-- valider si issnnum est el obligatoire sur les instances créées par Stylo-->
                    <idissnnum>
                        <xsl:value-of select="//journal-meta/issn[@publication-format='electronic']"
                        />
                    </idissnnum>

                    <!-- directeur (répétable ad infini) : 
                        1) att "sexe"  non traduite : aucune donnée dans texte source et el facultatif dans texte arrivée
                        2) je dois savoir quelle valeur de l'attribut "contrib-type" est utilisé par style pour désigner le titre de
                        directeur dans la balise "contrib". ici je prend la valeur "editor"
                        pour pouvoir tester le script-->

                    <xsl:if test="//article-meta/contrib-group/contrib[@contrib-type='editor']">
                        <xsl:for-each
                            select="//article-meta/contrib-group/contrib[@contrib-type='editor']">
                            <directeur>
                                <nompers>
                                    <prenom>
                                        <xsl:value-of select="./name/given-names"/>
                                    </prenom>
                                    <nomfamille>
                                        <xsl:value-of select="./name/surname"/>
                                    </nomfamille>
                                </nompers>
                            </directeur>
                        </xsl:for-each>
                    </xsl:if>
                    <!-- redacteur en chef (répétable ad infini) :  
                        1) att "sexe"  non traduite : aucune donnée dans texte source et el facultatif dans texte arrivée
                        2) je dois savoir quelle valeur de l'attribut "contrib-type" est utilisé par style pour désigner le titre de
                         directeur dans la balise "contrib". ici je prend la valeur inventée "guest-editor" pour pouvoir tester le script
                        3) att lang non présente dans les artéfacts, mais
                        4) att idref non presente dans les artéfacts -->

                    <xsl:if
                        test="//article-meta/contrib-group/contrib[@contrib-type='guest-editor']">
                        <xsl:for-each
                            select="//article-meta/contrib-group/contrib[@contrib-type='guest-editor']">
                            <redacteurchef typerc="invite">
                                <!--fonction (pour validité) :  1) att invité non présente dans les artéfacts, mais valeur "invite" mise par défaut 
                                                        2) att lang "fr" mise ar défaut-->
                                <fonction lang="fr">
                                    <xsl:value-of select="./role"/>
                                </fonction>
                                <nompers>
                                    <prenom>
                                        <xsl:value-of select="./name/given-names"/>
                                    </prenom>
                                    <nomfamille>
                                        <xsl:value-of select="./name/surname"/>
                                    </nomfamille>
                                </nompers>
                            </redacteurchef>
                        </xsl:for-each>
                    </xsl:if>

                </revue>
                <!--    att id de balise num: où aller puiser cette information? tenez-vous un catalogue?
                        sinon, article-meta/@issue-id, mais non présent sur les artéfacts-->
                <numero id="lorem-ipsum">
                    <pub>
                        <annee>
                            <xsl:value-of select="//pub-date[@date-type='pub']/year"/>
                        </annee>
                    </pub>
                    <pubnum>
                        <date>
                            <xsl:apply-templates
                                select="//pub-date[@publication-format='electronic']"/>
                        </date>
                    </pubnum>
                </numero>
                <!--  IB 2016-10-20 : Les balises editeur, prodnum et diffnum devraient normalement être balisées
                    par l'el role de contrib, dans contrib-group. Comme le type de contribution
                y est défini par une valeur d'attribut de contrib-type, il est impossible de savoir
                en ce moment comment extraire l'info, avec les artéfacts fournis.
                On remarque ici qu'il est nécessaire de normaliser ces valeurs d'attribut en amont afin de pouvoir
                transformer l'extrant de Stylo.
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
                    <alinea>néant</alinea>
                </histpapier>
                <!-- el schéma est du boilerplate -->
                <schema nom="Erudit Article" version="3.0.0" lang="fr"/>
                <droitsauteur>
                    <xsl:apply-templates select="//permissions"/>
                </droitsauteur>
            </xsl:element>
            <!-- ========================= el structurant Liminaire (OBL)==================================-->
            <liminaire>
                <grtitre>
                    <xsl:value-of select="//article-meta/title-group/article-title"/>
                </grtitre>
                <grauteur>
                    <xsl:for-each
                        select="//article-meta/contrib-group/contrib[@contrib-type='author']">
                        <auteur id="{current()/@id}">
                            <nompers>
                                <prenom>
                                    <xsl:value-of select="./name/given-names"/>
                                </prenom>
                                <nomfamille>
                                    <xsl:value-of select="./name/surname"/>
                                </nomfamille>
                            </nompers>
                        </auteur>
                    </xsl:for-each>
                </grauteur>
                <resume lang="fr">
                    <xsl:apply-templates
                        select="//article-meta/abstract[@abstract-type='executive-summary']"/>
                </resume>
                <xsl:element name="grmotcle" namespace="http://www.erudit.org/xsd/article">
                    <xsl:attribute name="lang">
                        <xsl:value-of select="'fr'"/>
                    </xsl:attribute>
                    <xsl:apply-templates
                        select="//article-meta/kwd-group[@kwd-group-type='author-keywords']"/>
                </xsl:element>
            </liminaire>
            <!-- ========================= el structurant corps (OBL) EN COURS==================================
            
            2016-10-24 : changé section1 pour section. -->
           
            <xsl:element name="corps" namespace="http://www.erudit.org/xsd/article">
                <xsl:apply-templates select="//body"/>
            </xsl:element>
            <!-- ========================= el structurant partiesann (FAC) ==================================-->

        </article>

    </xsl:template>
    <!-- ====================================== Templates ==================================-->




    <!-- ================ contenus mixtes ==================== -->
    <!-- ***********************figures************************************ 
    les objets d'information de type figure d"érudit sont un sous-groupe d'une balise
    plus générique dans jats
    image id : <xsl:value-of select="./graphic/@xlink:href" xpath-default-namespace="http://www.w3.org/1999/xlink"></xsl:value-of>-->

    <xsl:template match="fig/object-id">
        <xsl:element name="figure" namespace="http://www.erudit.org/xsd/article">
            <xsl:element name="objetmedia" namespace="http://www.erudit.org/xsd/article">
                <xsl:attribute name="flot">bloc</xsl:attribute>
                <xsl:element name="image">
                    <xsl:attribute name="typeimage"/>
                    <xsl:attribute name="desc"/>
                    <xsl:attribute name="id">img1164-1.jpg</xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <!-- *****************************resume**********************************
        sélection d'un des deux types d'abstracts présentés dans les artéfacts -->

    <!-- voir s'il faut mettre en place un "catch" pour empêcher l'affichage du dernier <p> qui, 
   dans les artéfacts fournis, montrent un doi et non du texte-->
    <xsl:template match="//article-meta/abstract[@abstract-type='executive-summary']">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- resume: traitement particulier des deux premières balises de <abstract> -->
    <xsl:template match="object-id"/>
    <xsl:template match="abstract/title"/>

    <!-- resume: pas de para, juste alinea -->
    <xsl:template match="abstract/p">
        <xsl:element name="alinea">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!--****************************corps****************************************-->

    
    <!-- vérifier si il y a des attributs dans la balise title -->
    <xsl:template match="title">
       <titre>
           <xsl:apply-templates/>
       </titre>
    </xsl:template>
    
    <xsl:template match="sec">
        <section>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <!-- para et alinea-->
    <xsl:template match="p">
        <para>
            <!-- voir si jats a l'équivalent de l'alinea -->
            <alinea>
                <xsl:apply-templates/>       
            </alinea>
        </para>
    </xsl:template>
    
    <!--liste-->
    <xsl:template match="list">
        <xsl:choose>
            <xsl:when test="@list-type='order'">
                <listeord>
                    <xsl:apply-templates/>
                </listeord>
            </xsl:when>
            <xsl:when test="@list-type='bullet'">
                <listenonord signe="disque">
                    <xsl:apply-templates/>
                </listenonord>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>toto</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
        <listeord>
            
        </listeord>
    </xsl:template>

    <!-- italique -->
    <xsl:template match="italic">
        <xsl:element name="marquage" namespace="http://www.erudit.org/xsd/article">
            <xsl:attribute name="typemarq">italique</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- renvois -->
    <!-- problème à résoudre : un seul attribut avec plusieurs valeurs dans le texte cible
    pour idref avec ce code
    
    IB : faire la liste des valeurs d'attribut qui doivent être normalisées dans stylo-->
    <xsl:template match="xref">
        <xsl:element name="renvoi" namespace="http://www.erudit.org/xsd/article">
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
 

    <!-- el grmotcle -->
    <xsl:template match="//article-meta/kwd-group[@kwd-group-type='author-keywords']">
        <xsl:for-each select="//article-meta/kwd-group[@kwd-group-type='author-keywords']/kwd">
            <xsl:element name="motcle" namespace="http://www.erudit.org/xsd/article">
                <xsl:value-of select="current()"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>




    <!-- droitsauteur -->
    <xsl:template match="//permissions">
        <xsl:value-of select="license/license-p"/>
        <nomorg>
            <xsl:value-of select="copyright-holder"/>
        </nomorg>, <xsl:value-of select="copyright-year"/>
    </xsl:template>

    <!-- el pubnum : date -->
    <xsl:template match="//pub-date[@publication-format='electronic']">
        <xsl:value-of select="./year"/>-<xsl:value-of select="./month"/>-<xsl:value-of
            select="./day"/>
    </xsl:template>
</xsl:stylesheet>
