<?xml version="1.0" encoding="UTF-8"?>
<x:stylesheet xmlns:x="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

	<x:output method="html" version="4.01" encoding="UTF-8"
		doctype-public="-//W3C//DTD HTML 4.01//EN"
		doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>

	<!-- TODO some of these variables should be merged with others -->
	<!--<x:variable name="doc" select="/list//*"/>-->
	<x:variable name="lang" select="//object[@name='acr:lang']/@current"/>
	<!-- IE doesn't understand relative paths so domain MUST be predefined -->
	<x:variable name="domain" select="//object[@name='acr:appDetails']/@domain"/>
	<x:variable name="config" select="//object[@name='acr:appDetails']/@config"/>
	<x:variable name="configdoc" select="document(concat('','../xml/',$config,'.xml'))/config"/>
	<x:variable name="langdoc" select="document(concat('../texts/',$lang,'.xml'))/t"/>
	<x:variable name="static" select="$configdoc/staticdomain/node()"/>
	<x:variable name="role" select="//object[@name='acr:user']/@role"/>
	<x:variable name="layoutdoc" select="//object[@name='layout']"/>
	<x:include href="widgets.xsl"/>

	<x:template match="/">
		<html>
		<head>
			<!-- TODO add datasource support -->
			<title>
				<x:for-each select="$layoutdoc/pagetitle/node()">
					<x:call-template name="template">
						<x:with-param name="datasource"><none/></x:with-param>
					</x:call-template>
				</x:for-each>
				-
				<x:for-each select="$configdoc/name/node()">
					<x:call-template name="template">
						<x:with-param name="datasource"><none/></x:with-param>
					</x:call-template>
				</x:for-each>
			</title>
			<meta name="description" content="{$configdoc/description/node()}"/>
			<meta name="keywords" content="{$configdoc/keywords/node()}"/>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7"/>
			<!-- export css and js to config.xml -->
			<link rel="stylesheet" type="text/css" href="http://e.acimg.eu/css/yui-rf.css"/>
			<link href="http://e.acimg.eu/css/grids.css" rel="stylesheet" type="text/css"/>
			<link href="{$static}css/style.css" rel="stylesheet" type="text/css"/>
			<x:for-each select="//style">
				<link href="{@url}" rel="stylesheet" type="text/css"/>
			</x:for-each>
			<script type="text/javascript" src="http://yui.yahooapis.com/combo?3.3.0/build/yui/yui-min.js&amp;3.3.0/build/loader/loader-min.js"></script>
			<script type="text/javascript" src="/js/init.js"/>
			<x:for-each select="//script[@url]">
				<script type="text/javascript" src="{@url}"/>
			</x:for-each>
			<x:if test="//item[@type='richText']">
				<script type="text/javascript" src="/js/richText.js"/>
			</x:if>
			<script type="text/javascript"><x:value-of select="//*[@name='layout']/script/node()"/></script>
		</head>
		<body>
			<x:apply-templates select="$layoutdoc"/>
			<x:if test="count(//object[@name='GlobalError'])">
				<h1>GlobalError <x:value-of select="//object[@name='GlobalError']/@error"/></h1>
				<x:copy-of select="//object[@name='GlobalError']/node()"/>
			</x:if>
		</body>
		</html>
	</x:template>

	<x:template match="container">
		<x:variable name="width">
			<x:value-of select="@width"/>
			<x:if test="not(@width)"><x:value-of select="$configdoc/defaultwidth/node()"/></x:if>
		</x:variable>
		<div class="container w{$width} {@name}">
			<x:apply-templates select="./*"/>
		</div>
	</x:template>

	<x:template match="column">
		<x:variable name="type">
			<x:value-of select="@type"/>
			<x:if test="not(@type)">last</x:if>
		</x:variable>
		<div class="column {$type} {@name}">
			<x:apply-templates select="./*"/>
		</div>
	</x:template>

	<x:template match="script|pagetitle|style"/>
	<x:template match="widget" name="widget">
		<x:param name="datasource" select="(//object|//list)[@name=current()/@datasource]"/>
		<x:variable name="tag">
			<x:value-of select="@tag"/>
			<x:if test="not(@tag)">div</x:if>
		</x:variable>
		<x:element name="{$tag}">
			<x:attribute name="id"><x:value-of select="@name"/></x:attribute>
			<x:variable name="before">
				<x:for-each select="before/node()">
					<x:call-template name="template">
						<x:with-param name="datasource" select="."/>
					</x:call-template>
				</x:for-each>
			</x:variable>
			<x:variable name="type">
				<x:value-of select="@type"/>
				<x:if test="not(@type)">template</x:if>
			</x:variable>

			<x:variable name="subtag">
				<x:value-of select="@subtag"/>
				<x:if test="not(@subtag)">div</x:if>
			</x:variable>
			<x:choose>
				<x:when test="local-name($datasource)='list' and count($datasource/object)">
					<x:attribute name="class">widget <x:value-of select="$type"/>-list <x:value-of select="@class"/></x:attribute>
					<x:copy-of select="$before"/>
					<x:variable name="this" select="."/>
					<x:variable name="subtagclass" select="@subtagclass"/>
					<x:if test="$role='admin'">
						<div class="accms-optionsPanel"/>
					</x:if>
					<x:for-each select="$datasource/object">
						<x:element name="{$subtag}">
							<x:attribute name="class">
								widget <x:value-of select="$type"/>-item
								<x:if test="position()=1">first </x:if>
								<x:value-of select="$subtagclass"/>
							</x:attribute>
							<x:apply-templates mode="widget" select="$this">
								<x:with-param name="datasource" select="."/>
							</x:apply-templates>
						</x:element>
					</x:for-each>
				</x:when>
				<x:otherwise>
					<x:attribute name="class">widget <x:value-of select="$type"/>-item <x:value-of select="@class"/></x:attribute>
					<x:copy-of select="$before"/>
					<x:apply-templates mode="widget" select=".">
						<x:with-param name="datasource" select="$datasource"/>
					</x:apply-templates>
				</x:otherwise>
			</x:choose>

			<x:for-each select="after/node()">
				<x:call-template name="template">
					<x:with-param name="datasource" select="."/>
				</x:call-template>
			</x:for-each>
		</x:element>
	</x:template>

	<x:template match="access">
		<a href="#" accesskey="{@key}"/>
	</x:template>
	<!-- TODO add required fields support -->
	<x:template match="widget[@type='form']" mode="widget">
		<x:param name="datasource" select="$doc//object[@name=current()/@datasource]"/>
		<form action="{@action}" method="post" enctype="multipart/form-data">
			<x:for-each select="*">
				<x:variable name="value">
					<x:variable name="helper" select="$datasource/*[name()=current()/@name]"/>
					<x:choose>
						<x:when test="@value">
							<x:copy-of select="//object[@name=current()/@value]/node()"/>
						</x:when>
						<x:when test="count(node())">
							<x:for-each select="node()">
								<x:call-template name="template">
									<x:with-param name="datasource" select="$datasource"/>
								</x:call-template>
							</x:for-each>
						</x:when>
						<x:otherwise>
							<x:copy-of select="$helper/node()"/>
						</x:otherwise>
					</x:choose>
				</x:variable>
				<x:choose>
					<x:when test="local-name(.)='widget'">
						<x:call-template name="widget">
							<x:with-param name="datasource" select="//*[@name=current()/@datasource]"/>
						</x:call-template>
					</x:when>
					<x:when test="local-name()='item' and @type='hidden'">
						<input id="{@name}" type="{@type}" name="{@name}" value="{$value}"/>
					</x:when>
					<x:when test="local-name()='item' and @type!='hidden'">
						<div class="item">
							<x:if test="count(@label)=0 or @label='enabled'">
								<label for="{@name}">
									<x:choose>
										<x:when test="count(@ml)">
											<x:value-of select="$langdoc//*[local-name()=current()/@ml]"/>
										</x:when>
										<x:otherwise>
											<x:value-of select="@name"/>
										</x:otherwise>
									</x:choose>
									<x:if test="@required='true'">
										<span class="required"> *</span>
									</x:if>
								</label>
							</x:if>
							<x:choose>
								<x:when test="@type='text' or @type='file' or @type='hidden' or @type='password'">
									<input id="{@name}" type="{@type}" name="{@name}" value="{$value}" accesskey="{@accesskey}"/>
								</x:when>
								<x:when test="@type='textarea'">
									<textarea id="{@name}" name="{@name}" accesskey="{@accesskey}"><x:copy-of select="$value"/></textarea>
								</x:when>
								<x:when test="@type='richText'">
									<textarea id="{@name}" name="{@name}" accesskey="{@accesskey}" class="richText"><x:value-of select="$value"/></textarea>
								</x:when>
								<x:when test="@type='checkbox'">
									<input id="{@name}" type="checkbox" name="{@name}" value="true" accesskey="{@accesskey}">
									<x:if test="$value='t' or @checked='true'">
										<x:attribute name="checked">checked</x:attribute>
									</x:if>
									</input>
								</x:when>
								<x:when test="@type='spinner'">
									<div class="spinner">
										<input id="{@name}" name="{@name}" type="text" class="yui-spinner-value" value="{$value}"/>
									</div>
								</x:when>
								<x:otherwise>
									<select id="{@name}" name="{@name}" accesskey="{@accesskey}">
										<x:if test="count(@multiple)">
											<x:attribute name="multiple">multiple</x:attribute>
										</x:if>
										<x:for-each select="//*[@name=current()/@type]/*">
											<x:variable name="optionValue">
												<x:choose>
													<x:when test="count(@value)=1"><x:value-of select="@value"/></x:when>
													<x:when test="count(value)"><x:value-of select="value"/></x:when>
													<x:otherwise><x:value-of select="."/></x:otherwise>
												</x:choose>
											</x:variable>
											<option value="{$optionValue}">
												<x:if test="$optionValue=$value">
													<x:attribute name="selected">selected</x:attribute>
												</x:if>
												<x:value-of select="$langdoc//*[local-name()=current()/@ml]|name|@name"/>
											</option>
										</x:for-each>
									</select>
								</x:otherwise>
							</x:choose>
						</div>
					</x:when>
					<x:otherwise>
						<x:copy-of select="."/>
					</x:otherwise>
				</x:choose>
			</x:for-each>
			<x:if test="not(@submit) or @submit!='none'">
				<input id="submit" name="submit" value="{$langdoc/submit/node()}" type="submit" accesskey="s"/>
			</x:if>
		</form>
	</x:template>

	<!--
		datasource is element with data for node
		context is template schema
	-->
	<x:template name="template">
		<x:param name="datasource"/>
		<x:choose>
			<x:when test="local-name(.)='ml'">
				<x:copy-of select="$langdoc//*[local-name()=current()/@name]/node()"/>
			</x:when>
			<x:when test="local-name(.)='node'">
				<x:copy-of select="$datasource//*[local-name()=current()/@name]/node()"/>
			</x:when>
			<x:when test="local-name(.)='attr'">
				<x:value-of select="$datasource/@*[local-name()=current()/@name]"/>
			</x:when>
			<x:when test="local-name(.)='widget'">
				<x:call-template name="widget">
					<x:with-param name="datasource" select="$datasource"/>
				</x:call-template>
			</x:when>
			<x:when test="not(name())">
				<x:value-of select="."/>
			</x:when>
			<x:otherwise>
				<x:element name="{local-name()}">
					<x:for-each select="@*">
						<x:attribute name="{local-name()}">
							<x:variable name="temp">
								<x:value-of select="."/>
								<x:for-each select="parent::*/pars[@for=local-name(current())]/node()">
									<x:call-template name="template">
										<x:with-param name="datasource" select="$datasource"/>
									</x:call-template>
								</x:for-each>
							</x:variable>
							<!--<x:value-of select="translate($temp, ' ', '_')"/>-->
							<x:value-of select="$temp"/>
						</x:attribute>
					</x:for-each>
					<!-- changed node() -> text()|* -->
					<x:for-each select="text()|*[local-name()!='pars']">
						<x:call-template name="template">
							<x:with-param name="datasource" select="$datasource"/>
						</x:call-template>
					</x:for-each>
				</x:element>
			</x:otherwise>
		</x:choose>
	</x:template>
</x:stylesheet>
