<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes" encoding="iso-8859-1"/>


    <!-- IB 2016-10-20 : Section "corps" en cours, besoin de voir quelles valeurs d'attributs seront utilisées
    pour structurer l'intrant.-->

    <!-- IB 2016-10-20 : le script génère automatiquement des attributs "xmlns" dans l'extrant pour certains éléments
    et je ne sais pas pourquoi. P.ex. : droitsauteur/nomorg 
        IB ajout 2016-10-20: remplacé certains éléments littéraux par l'utilisation de <xsl:element/> et <xsl:attribute/>
    et déclaré le namespace dans certains d'entres eux, en cours. pour l'instant, disparition d'ajout des attributs "xmlns" dans l'extrant-->

    <!-- IB 2016-10-19 : Preuve de concept. Prototype script pour validation Version 1.0
            Stratégie utilisée pour le script: 
            Réécriture complète de l'article en suivant l'arborescence du Schéma Érudit.
            Éléments structurants (complexes sans PCDATA) directement écrits dans le XSLT.
            Traitement du balisage orienté présentation fait par substitution.
            
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

    <!-- traitement balises de présentation -->

    <!--<xsl:template match="italic">
        <marquage typemarq="italique">
            <xsl:value-of select="current()"/>
        </marquage>
    </xsl:template> -->


    <xsl:template match="/">
        <!-- idproprio : il faut valider avec Érudit pour avoir la signification exacte de l'identifiant 
            et ainsi voir si la traduction est exacte  -->

        <article xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns="http://www.erudit.org/xsd/article"
            xsi:schemaLocation="http://www.erudit.org/xsd/article http://www.erudit.org/xsd/article/3.0.0/eruditarticle.xsd"
            qualtraitement="complet" idproprio="{//article-id[@pub-id-type='publisher-id']}"
            typeart="autre" lang="fr" ordseq="1">

            <!-- ========================= el structurant admin (OBL) ==================================-->

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
            <!-- ========================= el structurant corps (OBL) EN COURS==================================-->
            <xsl:element name="corps" namespace="http://www.erudit.org/xsd/article">
                <xsl:element name="section1" namespace="http://www.erudit.org/xsd/article">
                    <xsl:apply-templates select="//body"/>
                </xsl:element>
            </xsl:element>
            <!-- ========================= el structurant partiesann (FAC) ==================================-->

        </article>

    </xsl:template>
    <!-- ====================================== Templates ==================================-->




    <!-- section1 -->
    <xsl:template match="//body">
        <!-- regex pour nom de valeur d'attribut? -->
        <xsl:for-each select="sec[@id='s1']">
            <xsl:if test="./title">
                <xsl:element name="titre" namespace="http://www.erudit.org/xsd/article">
                    <xsl:value-of select="./title"/>
                </xsl:element>
            </xsl:if>
            <xsl:for-each select="./p">
                <xsl:element name="para" namespace="http://www.erudit.org/xsd/article">
                    <xsl:element name="alinea" namespace="http://www.erudit.org/xsd/article">
                        <xsl:value-of select="current()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>


    <!-- el grmotcle -->
    <xsl:template match="//article-meta/kwd-group[@kwd-group-type='author-keywords']">
        <xsl:for-each select="//article-meta/kwd-group[@kwd-group-type='author-keywords']/kwd">
            <xsl:element name="motcle" namespace="http://www.erudit.org/xsd/article">
                <xsl:value-of select="current()"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- resume -->
    <!-- voir s'il faut mettre en place un "catch" pour empêcher l'affichage du dernier <p> qui, 
   dans les artéfacts fournis, montrent un doi et non du texte-->
    <xsl:template match="//article-meta/abstract[@abstract-type='executive-summary']">
        <xsl:for-each select="//article-meta/abstract[@abstract-type='executive-summary']/p">
            <xsl:element name="para" namespace="http://www.erudit.org/xsd/article">
                <xsl:element name="alinea" namespace="http://www.erudit.org/xsd/article">
                    <xsl:value-of select="current()"/>
                </xsl:element>
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
