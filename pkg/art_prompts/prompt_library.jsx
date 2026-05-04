import { useState, useEffect } from "react";

const PROMPTS = [
  {
    id: "char-lea",
    category: "Personagem",
    label: "Léa Morel — Exploradora",
    icon: "🏃",
    target: ["Midjourney", "DALL·E 3", "Stable Diffusion"],
    description: "Personagem principal em corrida desesperada",
    mj: `photorealistic concept art, desperate female urban explorer sprinting through narrow Paris catacombs, late 20s, short dark hair, worn tactical jacket smeared with mud and white bone dust, chest-mounted oil lantern casting the only light source, dynamic shadows on stacked skull walls, expression of pure terror glancing over shoulder, motion blur on legs, cinematic composition 9:16 vertical, volumetric fog, deep shadow contrast, muted desaturated palette with warm amber lantern glow, unreal engine render quality, editorial horror photography style, highly detailed, 8k --ar 9:16 --v 6.1 --style raw`,
    dalle: `Ultra-realistic concept art for a mobile game character. A desperate female urban explorer (French, late 20s, athletic build, short dark hair) sprinting through a claustrophobic catacomb tunnel lined with human skulls and long bones. She wears a worn tactical jacket covered in mud and bone dust, with a chest-mounted oil lantern as the only light source. Her face shows pure terror as she glances back over her shoulder. The scene is lit exclusively by her lantern's warm amber glow creating dramatic volumetric shadows. Dark gothic atmosphere, 9:16 aspect ratio, cinematic quality, photorealistic.`,
    sd: `(photorealistic:1.4) female urban explorer, short dark hair, tactical jacket, chest lantern, bone dust, running desperately, Paris catacombs background, skull walls, (only lantern light:1.3), volumetric fog, terror expression, looking back, (dark gothic:1.2), cinematic composition, motion blur legs, 8k, detailed, --neg (cheerful, bright, colorful, cartoon, anime)`,
    variations: [
      "Altere para explorador masculino: 'male urban explorer, 30s, beard, worn field jacket'",
      "Versão exausta/rendição: remova 'sprinting' e adicione 'collapsed against wall, catching breath, lantern dim'",
      "Versão intro/título: adicione 'back to camera, facing dark tunnel ahead, silhouette against black'"
    ]
  },
  {
    id: "ankou-main",
    category: "Perseguidor",
    label: "O Ankou — Corpo Inteiro",
    icon: "💀",
    target: ["Midjourney", "DALL·E 3", "Stable Diffusion"],
    description: "Personificação da morte celta em perseguição",
    mj: `dark gothic horror concept art, the Ankou, ancient Celtic death specter, towering gaunt skeleton 2.2 meters tall, layered tattered black robes from different centuries floating like smoke, dilapidated Victorian silk top hat, elongated clawed skeletal fingers reaching forward, massive rusted ancient scythe 1.8m long, eye sockets glowing dim putrid green bioluminescence, silently float-sprinting through ossuary tunnel, camera low angle looking up creating imposing scale, absolute black background with green rim light, intricate fabric detail on robes, gothic horror illustration style, oil painting texture, dark color palette --ar 9:16 --v 6.1 --style raw --q 2`,
    dalle: `Dark gothic horror concept art of the Ankou, an ancient Celtic death personification. An impossibly tall (2.2m), gaunt skeletal figure wearing multiple layers of tattered black robes from different historical centuries that billow like black smoke. A decayed Victorian silk top hat sits atop its skull. Its elongated bony fingers reach forward as it pursues its prey. A massive rusted ancient scythe hangs at its side. Its empty eye sockets emit a dim, putrid green glow. Low-angle camera looking up creates an imposing sense of scale. Set in a dark catacomb tunnel with bone walls. Gothic horror illustration aesthetic, highly detailed, dark palette with green rim lighting.`,
    sd: `(gothic horror:1.4) ankou death specter, (gaunt skeleton:1.3) 2.2 meters tall, layered tattered black robes floating like smoke, victorian top hat, (glowing green eyes:1.4), elongated clawed fingers, massive rusted scythe, floating through catacombs, (low angle shot:1.2), bone dust particles, dark atmospheric, rim light green, intricate robe detail, oil painting style --neg (cute, friendly, colorful, cartoon, bright)`,
    variations: [
      "Aparição inicial/sombra: adicione 'barely visible, emerging from darkness, only eyes visible, silhouette impression'",
      "Close no rosto: 'extreme close-up face, hollow eye sockets glowing green, cracked ancient bone, rotting top hat brim above'",
      "Foice em detalhe: 'focus on massive rusted ancient scythe, intricate medieval metalwork detail, runes engraved on blade'"
    ]
  },
  {
    id: "ankou-approach",
    category: "Perseguidor",
    label: "O Ankou — Aproximação (POV)",
    icon: "👁️",
    target: ["Midjourney", "DALL·E 3"],
    description: "Ponto de vista do jogador vendo o Ankou se aproximar",
    mj: `first person horror game perspective, point-of-view shot looking back through narrow catacomb tunnel, distant figure of the Ankou growing larger, skeletal specter with glowing green eyes, tattered black robes filling the narrow corridor, walls of stacked skulls on both sides, warm amber lantern glow from foreground light source, dramatic depth of field with Ankou in sharp focus, green bioluminescent fog, dread atmosphere, photorealistic game screenshot quality, 16:9 --ar 16:9 --v 6.1 --style raw`,
    dalle: `A first-person horror game perspective showing a narrow Paris catacomb tunnel. Looking backward, the Ankou (a towering skeletal figure in billowing black robes) approaches in the distance, growing larger. Its eye sockets emit eerie green light that reflects off the walls of stacked skulls. The player's chest-mounted lantern casts warm amber light on the foreground, creating dramatic contrast with the cold green glow of the approaching specter. Photorealistic game screenshot quality, heavy vignette, volumetric fog, 16:9 aspect ratio.`,
    sd: ``,
    variations: [
      "Mais próximo/iminente: adicione 'Ankou much closer, filling 60% of frame, claws nearly reaching camera'",
      "Versão sombra distante: 'only silhouette visible at end of tunnel, two green pinpoints of light for eyes, very far away'"
    ]
  },
  {
    id: "env-ossuary",
    category: "Cenário",
    label: "Túnel Principal — Ossuário",
    icon: "🦴",
    target: ["Midjourney", "DALL·E 3", "Stable Diffusion"],
    description: "Corredor central de ossos humanos",
    mj: `photorealistic game environment concept art for mobile endless runner, Paris catacombs ossuary tunnel, claustrophobic narrow corridor, walls entirely constructed from meticulously stacked human skulls and femur bones in alternating layers, ceiling of ancient crumbling limestone, floor uneven wet stone with mud puddles reflecting light, a single amber headlight source from an unseen runner illuminates the scene casting dramatic moving shadows, piles of disorganized bones as obstacles on floor, low-hanging rotted wooden beam obstacle, absolute darkness beyond 15 meters, rendered in unreal engine 5, photorealistic materials, 16:9 --ar 16:9 --v 6.1 --q 2`,
    dalle: `Photorealistic 3D game environment concept art for a mobile endless runner game set in the Paris Catacombs. A narrow, claustrophobic tunnel corridor where both walls are constructed entirely from meticulously stacked human skulls and long bones arranged in alternating patterns (as seen in the real Paris ossuary). The ceiling is crumbling limestone. The floor is uneven wet stone with small mud puddles. A single warm amber light source from an unseen runner illuminates the scene, creating dramatic moving shadows. Random bone piles create natural obstacles on the floor. A single rotted wooden beam crosses at neck height. Beyond 15 meters, absolute darkness. Unreal Engine 5 quality, photorealistic.`,
    sd: `(photorealistic:1.4) Paris catacombs, narrow ossuary tunnel, skull walls both sides, stacked femur bones, (only one amber light source:1.3), deep shadows, wet stone floor, crumbling limestone ceiling, bone pile obstacles, low hanging wooden beam, (absolute darkness background:1.2), game environment, unreal engine 5, 16:9 --neg (colorful, bright, modern, clean)`,
    variations: [
      "Variação 'Criptas dos Reis': substitua por 'marble tomb niches, broken stone sarcophagi, royal heraldic carvings, iron gate obstacles'",
      "Variação 'Esgotos Inundados': 'flooded tunnel, 30cm water on floor, iron pipes on walls, green algae, water reflections of lantern'",
      "Variação 'Câmaras dos Monges': 'vaulted gothic ceiling, stone pews, religious iconography, broken stained glass fragments on floor'"
    ]
  },
  {
    id: "env-crypt",
    category: "Cenário",
    label: "Criptas dos Reis",
    icon: "⚰️",
    target: ["Midjourney", "DALL·E 3"],
    description: "Área alternativa — câmaras reais",
    mj: `photorealistic game environment, Paris royal crypt level, wide gothic vaulted chamber, ornate marble tomb niches along both walls with carved stone effigies of medieval kings, cracked sarcophagi as obstacles, iron gate hanging at angle partially blocking path, cobwebs on stone carving, amber lantern glow reflecting off polished marble, fallen stone blocks, heraldic carvings half-eroded, deep shadows in alcoves, 16:9 game art --ar 16:9 --v 6.1 --style raw`,
    dalle: `Game environment concept art for 'Crypts of Kings' level. A wide gothic vaulted chamber in the Paris catacombs. Ornate marble tomb niches line both walls containing carved stone effigies of medieval French kings. Cracked stone sarcophagi make natural obstacles. A heavy iron gate hangs at an angle partially blocking the path. Ancient cobwebs cover the heraldic carvings. A single amber lantern reflects off polished marble surfaces. Fallen stone blocks litter the floor. Deep shadows fill the alcoves. Photorealistic 16:9 game concept art.`,
    sd: ``,
    variations: [
      "Versão inundada: adicione 'ankle-deep black water, tomb niches reflected in water surface, eerie stillness'",
      "Versão colapsada: 'ceiling partially collapsed, rubble blocking two thirds of corridor, narrow passage on left'"
    ]
  },
  {
    id: "env-sewer",
    category: "Cenário",
    label: "Esgotos Inundados",
    icon: "💧",
    target: ["Midjourney", "DALL·E 3"],
    description: "Área alternativa — túneis de esgoto",
    mj: `photorealistic game environment, Paris underground sewer tunnel level for endless runner game, circular brick tunnel, 30cm black stagnant water on floor reflecting amber lantern, iron pipes and valves along curved walls, green algae and moss on brickwork, wooden planks as makeshift bridges over deeper sections, dripping water creating ripples, absolute darkness ahead, fog on water surface, gothic horror atmosphere, Unreal Engine 5 render --ar 16:9 --v 6.1`,
    dalle: `Photorealistic 3D game environment: a flooded Paris underground sewer tunnel set in gothic horror style. A circular brick tunnel with 30cm of black stagnant water on the floor perfectly reflecting an amber lantern light. Iron pipes, valves and chains run along the curved walls. Green algae and moss cling to the brickwork. Wooden planks serve as makeshift bridges over deeper flooded sections. Dripping water creates ripple effects. Dense fog hovers over the water surface. Absolute darkness ahead beyond 12 meters. Unreal Engine 5 quality lighting and materials. 16:9.`,
    sd: ``,
    variations: [
      "Versão escoamento: 'water rushing in one direction, current visible, debris floating, character fighting current'",
      "Versão teto baixo: 'pipes at chest height force crouching, claustrophobic low ceiling, more intense vignette'"
    ]
  },
  {
    id: "obs-bones",
    category: "Obstáculos",
    label: "Obstáculos — Conjunto Completo",
    icon: "⚠️",
    target: ["Midjourney", "DALL·E 3"],
    description: "Sheet de referência de obstáculos do jogo",
    mj: `game concept art reference sheet, 5 different catacomb obstacles on dark background, labeled: 1) pile of human skulls and femur bones 1 meter high, 2) rotted medieval wooden beam at neck height, 3) dark bottomless pit in stone floor with worn edges, 4) wall of skulls floor-to-ceiling with low archway, 5) three medieval iron lance trap triggered by floor pressure. each obstacle rendered in warm amber lantern light, gothic horror game art style, 3D rendered, white spacing between each, dark background --ar 16:9 --v 6.1`,
    dalle: `Game concept art reference sheet showing 5 different catacomb obstacles for a gothic endless runner game. Each obstacle is clearly separated and labeled, rendered in warm amber lantern lighting against a dark background: (1) A knee-high pile of human skulls and femur bones. (2) A rotted medieval wooden beam crossing at neck height. (3) A dark bottomless pit in the stone floor with worn edges. (4) A wall of stacked skulls from floor to ceiling with only a small low archway for passage. (5) Three medieval iron lance traps that spring from the floor. Gothic horror 3D game art style. 16:9 reference sheet layout.`,
    sd: ``,
    variations: [
      "Obstáculos individuais: use só o item desejado e remova os outros para renders em alta resolução",
      "Versão animada: adicione 'motion lines, dust particles, dynamic pose at moment of spring/appearance'"
    ]
  },
  {
    id: "powerup-sheet",
    category: "UI / Itens",
    label: "Power-Ups — Sheet de Ícones",
    icon: "✨",
    target: ["Midjourney", "DALL·E 3"],
    description: "5 power-ups do jogo em estilo gótico",
    mj: `game icon concept art sheet, 5 gothic mystical power-up items for dark catacomb game, isolated on black background, each in separate ornate carved bone frame: 1) sacred glowing amber lantern, 2) glass vial with glowing white ancestral bone powder, 3) spectral blue speed lines emanating from running footprints, 4) sacred human rib bone with carved death rune glowing gold, 5) billowing black silk veil with green spectral glow, dark gothic illustration style, game-ready icon art, highly detailed --ar 16:9 --v 6.1`,
    dalle: `Game icon concept art sheet for 5 gothic power-up items in a Paris catacombs game. Each item is isolated on a black background in an ornate carved bone frame: (1) A sacred oil lantern radiating golden amber light. (2) A glass vial containing glowing white ancestral bone powder. (3) Spectral blue speed lines emanating from ghost footprints (Sprint Spectral). (4) A sacred human rib bone with a glowing golden death rune carved into it. (5) A billowing black silk veil with eerie green spectral glow (Veil of Shadow). Dark gothic game illustration style, suitable for mobile UI icons, highly detailed. 16:9 reference sheet.`,
    sd: ``,
    variations: [
      "Ícones individuais (64×64): adicione 'single icon, perfect square composition, clean edges, mobile game icon format'",
      "Versão animada/glowing: adicione 'particle emission, light bloom, subtle floating animation implied'"
    ]
  },
  {
    id: "ui-hud",
    category: "UI / Itens",
    label: "HUD e Interface do Jogo",
    icon: "📱",
    target: ["Midjourney", "DALL·E 3"],
    description: "Interface completa na tela durante o jogo",
    mj: `mobile game UI design mockup for gothic endless runner, 9:16 phone screen, dark gothic catacomb game interface, top left: distance counter in aged iron frame with gothic numerals showing 2847m, top right: threat bar labeled ANKOU in dark iron frame with 4 skull pips (2 red 2 dark), small green life bar draining, bottom center: item slot showing glowing vial icon in ornate bone frame, all UI elements made of carved bone and dark iron with skull decorations, heavy gothic serif typeface, dark amber and crimson color palette, transparent overlays, game screenshot style --ar 9:16 --v 6.1`,
    dalle: `Mobile game UI design for a gothic endless runner (9:16 vertical phone screen). The interface elements are crafted from aged dark iron and carved bone with skull decorations. Top left: a distance counter in an ornate iron frame showing '2847m' in gothic numerals. Top right: an ANKOU threat tracker showing a draining life bar and 4 skull pip indicators (2 red, 2 dark). Bottom center: an item slot showing a glowing vial icon in an ornate bone frame. Heavy gothic serif typography throughout. Dark amber (#B8943A) and crimson (#7C1A10) color palette. Semi-transparent overlays. Realistic game screenshot showing a catacomb background behind the UI.`,
    sd: ``,
    variations: [
      "Tela de título: 'main menu screen, OSSUARY ESCAPE title in carved bone letters, start button, dark catacomb background'",
      "Game over screen: 'YOU WERE CAUGHT screen, Ankou silhouette, score display, play again button, gothic design'",
      "Tela de loja: 'character skin selection screen, 5 character cards, Relíquia currency display, gothic storefront'"
    ]
  },
  {
    id: "ui-gameover",
    category: "UI / Itens",
    label: "Tela de Game Over",
    icon: "☠️",
    target: ["Midjourney", "DALL·E 3"],
    description: "Tela cinematográfica de captura pelo Ankou",
    mj: `gothic mobile game over screen, 9:16 vertical, the Ankou skeletal figure looming large covering upper 60% of screen with outstretched clawed hand toward camera, glowing green eyes, tattered robes filling frame, below: carved stone slab with gothic text 'CAPTURADO' in blood-red letters, score displayed in gold gothic numerals on aged parchment, two buttons at bottom: 'MOEDA DE CARONTE' (golden coin icon) and 'RECOMEÇAR' (skull icon), heavy grain film effect, desaturated dark atmosphere --ar 9:16 --v 6.1`,
    dalle: `Gothic mobile game 'Game Over' screen in 9:16 vertical format. The Ankou skeletal specter looms large filling the upper 60% of the screen, its tattered robes billowing outward, green glowing eyes staring at the player, one elongated clawed hand reaching toward the camera. Below this dramatic figure, a carved stone slab displays 'CAPTURADO' in blood-red gothic letters. A score of '3,247m' appears in gold gothic numerals on aged parchment. At the bottom, two buttons: 'MOEDA DE CARONTE' with a golden coin icon, and 'RECOMEÇAR' with a skull icon. Heavy film grain, dark desaturated palette.`,
    sd: ``,
    variations: [
      "Versão recorde batido: adicione 'golden confetti made of bone fragments, NEW RECORD text glowing gold above score'",
      "Versão primeira morte: adicione 'tutorial overlay, arrow pointing to RECOMEÇAR button, softer Ankou presence'"
    ]
  },
  {
    id: "key-art",
    category: "Marketing",
    label: "Arte Principal — App Store",
    icon: "🎨",
    target: ["Midjourney", "DALL·E 3"],
    description: "Banner principal para lojas de apps",
    mj: `cinematic key art for gothic mobile game Ossuary Escape, wide 16:9 composition, left: female urban explorer in full sprint through catacomb tunnel, amber lantern chest light, motion blur, expression of desperate terror, right: enormous Ankou skeletal specter filling the tunnel behind her, green glowing eyes, rusted scythe, tattered robes, perfect visual contrast warm amber vs cold green, skull walls on both sides, dramatic forced perspective making Ankou look impossibly large, movie poster quality composition, gothic horror aesthetic, highly detailed, 8k --ar 16:9 --v 6.1 --q 2 --style raw`,
    dalle: `Cinematic key art for the mobile game 'Ossuary Escape'. A wide 16:9 movie-poster composition. On the left, a female urban explorer sprints desperately through a narrow Paris catacomb tunnel (skull walls visible on both sides). Her chest-mounted amber lantern is the only warm light source, illuminating her terrified face as she looks back. On the right, towering behind her, the Ankou fills the entire tunnel: a gaunt skeletal specter 2.2 meters tall in billowing multi-layered black robes, Victorian top hat, glowing green eyes, massive rusted scythe. The warm amber of the lantern vs the cold green of the Ankou creates dramatic visual contrast. Forced perspective makes the Ankou appear impossibly large. Movie poster quality, gothic horror, 8k detail.`,
    sd: ``,
    variations: [
      "Versão retrato (9:16) para stories: 'vertical 9:16 composition, character at bottom running up, Ankou above looking down'",
      "Versão ícone do app (1:1): 'square crop, just the Ankou face close-up, green eyes, top hat, catacomb arch framing'"
    ]
  },
  {
    id: "key-icon",
    category: "Marketing",
    label: "Ícone do Aplicativo",
    icon: "📲",
    target: ["Midjourney", "DALL·E 3"],
    description: "Ícone quadrado para lojas",
    mj: `mobile app icon design, perfect 1:1 square format, gothic horror game icon for Ossuary Escape, centered: Ankou skull face close-up, hollow eye sockets glowing intense green, dilapidated top hat, tattered robe collar, framed by gothic stone arch carved with small skulls, dark background gradient black to deep crimson at edges, game title OSSUARY ESCAPE in small gothic letters at bottom, carved bone frame around entire icon, premium mobile game icon quality, flat design with depth, high contrast --ar 1:1 --v 6.1`,
    dalle: `Mobile app icon for 'Ossuary Escape' game. Perfect square (1:1) format. Centered: a close-up of the Ankou's skull face — hollow eye sockets glowing intense green, a dilapidated Victorian top hat, tattered black robe collar visible below. The skull is framed by a gothic stone arch carved with small decorative skulls. Dark background with a gradient from pure black at center to deep crimson (#7C1A10) at the edges. 'OSSUARY ESCAPE' appears in small gothic letters at the bottom. An ornate carved bone border frames the entire icon. Premium mobile game icon aesthetic with high contrast and visual impact.`,
    sd: ``,
    variations: [
      "Versão minimalista: 'just two glowing green eyes in darkness, no other details, extremely minimal, maximum impact'",
      "Versão com lanterna: 'lantern as main element instead of Ankou, warm amber glow in darkness, gothic frame, mysterious'"
    ]
  },
  {
    id: "concept-world",
    category: "Marketing",
    label: "Mapa das Catacumbas",
    icon: "🗺️",
    target: ["Midjourney", "DALL·E 3"],
    description: "Mapa estilizado para meta-jogo de progressão",
    mj: `antique hand-drawn map illustration, Paris underground catacombs stylized as gothic treasure map, aged parchment background with burn marks at edges, ink illustration style, 5 distinct areas labeled in gothic calligraphy: Entrée des Catacombes, Ossuaires Anciens, Cryptes des Rois, Passages Profonds, Domaine de l'Ankou, decorative skull compass rose, small illustrated icons for each area (bone piles, crypts, carved kings, dark tunnels, Ankou silhouette), connecting tunnel paths in ink, some areas covered in black ink fog of war, 16:9 --ar 16:9 --v 6.1`,
    dalle: `An antique hand-drawn map illustration of the Paris underground catacombs for a gothic game. Rendered on aged parchment with burn marks at the edges, in a detailed ink illustration style. Five distinct areas are labeled in gothic calligraphy: 'Entrée des Catacombes' (entrance), 'Ossuaires Anciens' (old ossuaries), 'Cryptes des Rois' (king's crypts), 'Passages Profonds' (deep passages), 'Domaine de l'Ankou' (darkest area, partially obscured by black ink as fog of war). A decorative compass rose made of crossed bones. Small illustrated vignettes mark each area. Connecting tunnel paths drawn in ink. Atmospheric and foreboding.`,
    sd: ``,
    variations: [
      "Versão parcialmente revelada: 'fog of war covering 3 of 5 areas, only first two areas visible, mystery element strong'",
      "Versão decorativa/poster: 'no game UI context, purely decorative art, ornate border, suitable for physical print'"
    ]
  },
];

const CATEGORIES = ["Todos", "Personagem", "Perseguidor", "Cenário", "Obstáculos", "UI / Itens", "Marketing"];

const TARGET_COLORS = {
  "Midjourney": { bg: "#1a1a2e", border: "#4a4a8a", text: "#8888ff" },
  "DALL·E 3":   { bg: "#1a2a1a", border: "#3a7a3a", text: "#6aaa6a" },
  "Stable Diffusion": { bg: "#2a1a1a", border: "#7a3a3a", text: "#cc6666" },
};

function CopyButton({ text }) {
  const [copied, setCopied] = useState(false);
  const copy = () => {
    navigator.clipboard.writeText(text).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  };
  return (
    <button onClick={copy} style={{
      background: copied ? "#2a4a2a" : "#1a1a1a",
      border: `1px solid ${copied ? "#4a8a4a" : "#3a2a14"}`,
      color: copied ? "#6aaa6a" : "#b8943a",
      padding: "5px 12px", borderRadius: "4px", cursor: "pointer",
      fontSize: "11px", fontFamily: "monospace", transition: "all 0.2s",
      letterSpacing: "0.5px",
    }}>
      {copied ? "✓ COPIADO" : "COPIAR"}
    </button>
  );
}

function PromptBlock({ label, content, color }) {
  if (!content) return null;
  return (
    <div style={{ marginBottom: "14px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "6px" }}>
        <span style={{
          fontSize: "10px", fontFamily: "monospace", letterSpacing: "1.5px", fontWeight: "bold",
          background: color.bg, border: `1px solid ${color.border}`,
          color: color.text, padding: "2px 8px", borderRadius: "3px",
        }}>{label}</span>
        <CopyButton text={content} />
      </div>
      <div style={{
        background: "#0a0805", border: "1px solid #2a1a08",
        borderRadius: "6px", padding: "12px 14px",
        fontFamily: "monospace", fontSize: "11.5px", lineHeight: "1.7",
        color: "#c8b890", whiteSpace: "pre-wrap", wordBreak: "break-word",
        maxHeight: "160px", overflowY: "auto",
      }}>{content}</div>
    </div>
  );
}

export default function PromptLibrary() {
  const [cat, setCat] = useState("Todos");
  const [open, setOpen] = useState(null);
  const [search, setSearch] = useState("");

  const filtered = PROMPTS.filter(p =>
    (cat === "Todos" || p.category === cat) &&
    (search === "" || p.label.toLowerCase().includes(search.toLowerCase()) || p.description.toLowerCase().includes(search.toLowerCase()))
  );

  useEffect(() => { setOpen(null); }, [cat, search]);

  return (
    <div style={{
      minHeight: "100vh", background: "#080604",
      fontFamily: "'Georgia', serif", color: "#e8d8b8",
    }}>
      {/* Header */}
      <div style={{
        background: "linear-gradient(180deg, #0f0a06 0%, #080604 100%)",
        borderBottom: "2px solid #7c1a10",
        padding: "28px 24px 20px",
        position: "sticky", top: 0, zIndex: 100,
      }}>
        <div style={{ maxWidth: "900px", margin: "0 auto" }}>
          <div style={{ display: "flex", alignItems: "baseline", gap: "12px", marginBottom: "4px" }}>
            <span style={{ fontSize: "11px", letterSpacing: "3px", color: "#7c1a10", fontFamily: "monospace" }}>✦ OSSUARY ESCAPE</span>
          </div>
          <h1 style={{ margin: "0 0 4px", fontSize: "26px", fontWeight: "bold", color: "#d4ae48", letterSpacing: "1px" }}>
            Biblioteca de Prompts de Imagem
          </h1>
          <p style={{ margin: "0 0 18px", fontSize: "13px", color: "#6a5848" }}>
            {PROMPTS.length} prompts refinados · Midjourney · DALL·E 3 · Stable Diffusion
          </p>

          {/* Search */}
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Buscar prompt..."
            style={{
              width: "100%", maxWidth: "340px", background: "#0d0a07",
              border: "1px solid #3a2a14", borderRadius: "5px",
              padding: "8px 12px", color: "#e8d8b8", fontFamily: "Georgia, serif",
              fontSize: "13px", outline: "none", marginBottom: "14px",
              boxSizing: "border-box",
            }}
          />

          {/* Category pills */}
          <div style={{ display: "flex", flexWrap: "wrap", gap: "8px" }}>
            {CATEGORIES.map(c => (
              <button key={c} onClick={() => setCat(c)} style={{
                background: cat === c ? "#7c1a10" : "#0d0a07",
                border: `1px solid ${cat === c ? "#c0371e" : "#3a2a14"}`,
                color: cat === c ? "#e8d8b8" : "#6a5848",
                padding: "5px 14px", borderRadius: "20px", cursor: "pointer",
                fontSize: "12px", fontFamily: "Georgia, serif",
                transition: "all 0.18s",
              }}>{c}</button>
            ))}
          </div>
        </div>
      </div>

      {/* Cards */}
      <div style={{ maxWidth: "900px", margin: "0 auto", padding: "20px 24px 60px" }}>
        {filtered.length === 0 && (
          <div style={{ textAlign: "center", color: "#3a2a14", padding: "60px", fontSize: "14px" }}>
            Nenhum prompt encontrado.
          </div>
        )}
        {filtered.map(p => (
          <div key={p.id} style={{
            background: "#0d0a07", border: `1px solid ${open === p.id ? "#b8943a" : "#1e140a"}`,
            borderRadius: "8px", marginBottom: "12px", overflow: "hidden",
            transition: "border-color 0.2s",
          }}>
            {/* Card header */}
            <button onClick={() => setOpen(open === p.id ? null : p.id)} style={{
              width: "100%", background: "none", border: "none",
              padding: "16px 20px", cursor: "pointer", textAlign: "left",
              display: "flex", alignItems: "center", gap: "14px",
            }}>
              <span style={{ fontSize: "22px", flexShrink: 0 }}>{p.icon}</span>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "3px", flexWrap: "wrap" }}>
                  <span style={{ fontSize: "15px", fontWeight: "bold", color: "#d4ae48" }}>{p.label}</span>
                  <span style={{
                    fontSize: "10px", letterSpacing: "1.5px", fontFamily: "monospace",
                    background: "#1a0e06", border: "1px solid #3a2010",
                    color: "#7a5028", padding: "1px 7px", borderRadius: "3px",
                  }}>{p.category.toUpperCase()}</span>
                </div>
                <span style={{ fontSize: "12px", color: "#6a5848" }}>{p.description}</span>
              </div>
              <div style={{ display: "flex", gap: "6px", flexShrink: 0, flexWrap: "wrap" }}>
                {p.target.map(t => (
                  <span key={t} style={{
                    fontSize: "9px", letterSpacing: "0.5px", fontFamily: "monospace",
                    background: TARGET_COLORS[t]?.bg || "#111",
                    border: `1px solid ${TARGET_COLORS[t]?.border || "#333"}`,
                    color: TARGET_COLORS[t]?.text || "#888",
                    padding: "2px 6px", borderRadius: "3px",
                  }}>{t.replace("Stable Diffusion","SD")}</span>
                ))}
              </div>
              <span style={{ color: "#3a2a14", fontSize: "16px", marginLeft: "8px", flexShrink: 0 }}>
                {open === p.id ? "▲" : "▼"}
              </span>
            </button>

            {/* Expanded content */}
            {open === p.id && (
              <div style={{
                borderTop: "1px solid #1e140a", padding: "20px 20px 16px",
                animation: "fadeIn 0.15s ease",
              }}>
                {p.mj && <PromptBlock label="MIDJOURNEY" content={p.mj} color={TARGET_COLORS["Midjourney"]} />}
                {p.dalle && <PromptBlock label="DALL·E 3" content={p.dalle} color={TARGET_COLORS["DALL·E 3"]} />}
                {p.sd && <PromptBlock label="STABLE DIFFUSION" content={p.sd} color={TARGET_COLORS["Stable Diffusion"]} />}

                {p.variations && p.variations.length > 0 && (
                  <div style={{ marginTop: "16px" }}>
                    <div style={{
                      fontSize: "10px", fontFamily: "monospace", letterSpacing: "1.5px",
                      color: "#5a4a28", marginBottom: "8px",
                    }}>VARIAÇÕES SUGERIDAS</div>
                    {p.variations.map((v, i) => (
                      <div key={i} style={{
                        display: "flex", gap: "10px", marginBottom: "6px",
                        padding: "8px 12px", background: "#0a0805",
                        border: "1px solid #1a1208", borderRadius: "4px",
                      }}>
                        <span style={{ color: "#7c1a10", flexShrink: 0, fontSize: "13px" }}>›</span>
                        <span style={{ fontSize: "12px", color: "#7a6848", lineHeight: "1.5", fontFamily: "monospace" }}>{v}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        ))}

        {/* Footer tips */}
        <div style={{
          marginTop: "32px", padding: "20px 24px",
          background: "#0a0805", border: "1px solid #1e140a", borderRadius: "8px",
        }}>
          <div style={{ fontSize: "11px", letterSpacing: "2px", color: "#5a3a18", marginBottom: "12px", fontFamily: "monospace" }}>
            ✦ DICAS DE USO
          </div>
          {[
            ["Midjourney", "Os parâmetros --ar, --v, --style e --q já estão incluídos. Cole o prompt inteiro no /imagine."],
            ["DALL·E 3", "Funciona melhor com descrições em inglês detalhadas. O ChatGPT Plus tem acesso direto."],
            ["Stable Diffusion", "Use os pesos (1.3) com atenção. Adicione seu LoRA de estilo gothic_horror_v2 para melhores resultados."],
            ["Coerência Visual", "Para múltiplas imagens, mantenha sempre: 'amber lantern only light source', 'skull bone walls', 'gothic horror' nos prompts do cenário."],
          ].map(([k, v]) => (
            <div key={k} style={{ display: "flex", gap: "12px", marginBottom: "8px" }}>
              <span style={{ fontFamily: "monospace", fontSize: "11px", color: "#b8943a", flexShrink: 0, minWidth: "140px" }}>{k}</span>
              <span style={{ fontSize: "12px", color: "#5a4a38", lineHeight: "1.5" }}>{v}</span>
            </div>
          ))}
        </div>
      </div>

      <style>{`
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-4px); } to { opacity: 1; transform: translateY(0); } }
        ::-webkit-scrollbar { width: 6px; } ::-webkit-scrollbar-track { background: #080604; }
        ::-webkit-scrollbar-thumb { background: #2a1a08; border-radius: 3px; }
        * { box-sizing: border-box; }
      `}</style>
    </div>
  );
}
