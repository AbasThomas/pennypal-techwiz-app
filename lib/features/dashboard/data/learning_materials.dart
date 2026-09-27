import 'package:bootstrap_flutter/core/widgets/app_icon.dart';

class LearningBook {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String level;
  final int readTimeMinutes;
  final int chapterCount;
  final List<List<dynamic>> icon;
  final String author;
  final String summary;
  final List<BookChapter> chapters;

  const LearningBook({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.level,
    required this.readTimeMinutes,
    required this.chapterCount,
    required this.icon,
    required this.author,
    required this.summary,
    required this.chapters,
  });
}

class BookChapter {
  final String number;
  final String title;
  final String readTime;
  final String summary;
  final String content;
  final List<String> takeaways;

  const BookChapter({
    required this.number,
    required this.title,
    required this.readTime,
    required this.summary,
    required this.content,
    required this.takeaways,
  });
}

class LearningRepository {
  static const List<LearningBook> curatedBooks = [
    LearningBook(
      id: 'campus-money-playbook',
      title: 'The Campus Money Playbook',
      subtitle: 'From Broke Student to Financially Fearless',
      category: 'Budgeting & Habits',
      level: 'Beginner',
      readTimeMinutes: 12,
      chapterCount: 4,
      icon: AppIcons.book,
      author: 'PennyPal Financial Academy',
      summary:
          'The definitive student playbook for mastering monthly allowances, eliminating unmonitored account leaks, and budgeting for Nigerian campus life.',
      chapters: [
        BookChapter(
          number: '01',
          title: 'The Harsh Truth About Student Pocket Money',
          readTime: '3 min read',
          summary: 'Why monthly allowances disappear in the first 10 days and how to stop accidental account leaks.',
          content: '''
Most students experience the "First-Week Wealth, Last-Week Sapa" cycle. On day one of getting your monthly allowance or pocket money, you feel rich. You order food delivery, buy new outfits, and say "put it on my bill."

By day 12, reality hits. Your account balance is staring back at you with three digits, and there are still 18 days left in the month.

The culprit is rarely the big expenses — it is the untracked micro-spending:
1. Daily snacks, soft drinks, and campus cafeteria markups.
2. Airtime and data top-ups bought in small ₦500 increments without checking total volume.
3. Unplanned Uber/Bolt rides when you could have left 10 minutes earlier.

The Golden Rule: You cannot manage what you do not measure. Every single Naira leaving your account must have a designated purpose before the month begins.
''',
          takeaways: [
            'Separate your allowance into 4 weekly envelopes or digital pots instead of spending from one lump sum.',
            'Track your daily data and snack expenses for 7 days — you will be shocked at how much leaks out.',
            'Always pay your core commitments (rent, syllabus/course materials, utilities) before buying lifestyle items.',
          ],
        ),
        BookChapter(
          number: '02',
          title: 'The 50/30/20 Rule for Nigerian Campuses',
          readTime: '3 min read',
          summary: 'Customizing the famous budgeting framework to real Nigerian student realities.',
          content: '''
The traditional 50/30/20 rule states:
- 50% for Needs (Food, Housing, Transport, Textbooks)
- 30% for Wants (Movies, Eating out, Socials, Fashion)
- 20% for Savings and Emergency preparation.

On a Nigerian campus, you need to adjust this to account for local economic realities:
- 60% Core Living: Hostels, cooking raw ingredients in bulk, hostel electricity, course materials.
- 20% Lifestyle & Social: Outings with course mates, data subscriptions, personal grooming.
- 20% Untouchable Savings: Directly locked in a dedicated savings goal on PennyPal.

Buying food items in bulk (e.g. rice, beans, garri, cooking oil) with roommates cuts monthly feeding costs by up to 45% compared to daily cafeteria takeout.
''',
          takeaways: [
            'Cooking raw ingredients with roommates is 2x to 3x cheaper than daily fast food or canteen purchases.',
            'Automate your 20% savings the exact day your allowance arrives — before you spend a single Naira.',
            'Cap your weekly entertainment budget and do not dip into core living funds when it runs out.',
          ],
        ),
        BookChapter(
          number: '03',
          title: 'The ₦500 Daily Micro-Savings Rule',
          readTime: '3 min read',
          summary: 'How small, painless daily amounts compound into serious financial safety.',
          content: '''
Many students believe they cannot save because they don't have large sums of money. This is a dangerous myth. Financial discipline is a muscle built through consistency, not income size.

Consider the math of small daily deposits:
- ₦500 saved every day = ₦15,000 in 30 days.
- In a 9-month academic session = ₦135,000.
- With ₦1,000 saved daily = ₦270,000.

This is enough to comfortably pay for:
- Next session's off-campus hostel rent deposit.
- Professional certification exams (e.g. ICAN, ACCA, AWS, UI/UX bootcamps).
- Emergency medical care or broken smartphone repairs without begging anyone.
''',
          takeaways: [
            'Consistency always beats intensity in personal finance.',
            'Set up a PennyPal Daily Target Savings Goal for ₦500 or ₦1,000.',
            'Treat your daily savings like a non-negotiable expense that you owe to your future self.',
          ],
        ),
        BookChapter(
          number: '04',
          title: 'The 48-Hour Impulsive Purchase Shield',
          readTime: '3 min read',
          summary: 'Defeating online shopping traps, flash sales, and peer pressure spending.',
          content: '''
Campus culture thrives on social comparison. When friends order expensive meals or buy matching trending sneakers, the psychological urge to fit in is immense.

Marketers exploit this through urgency: "Only 2 items left in stock!" or "Sale ends tonight!"

To protect your wallet, adopt the 48-Hour Rule:
Whenever you see a non-essential item you desperately want to buy (clothes, gadgets, footwear, luxury perfumes), force yourself to wait exactly 48 hours before paying.

In over 80% of cases, the dopamine rush fades, logic takes over, and you realize you never needed the item in the first place.
''',
          takeaways: [
            'Never buy non-essential items on impulse — enforce a mandatory 48-hour cool-off period.',
            'Remember: People only post their highlights on social media, not their empty bank accounts.',
            'True financial status is what you have saved in assets, not what you show off on your feet.',
          ],
        ),
      ],
    ),
    LearningBook(
      id: 'emergency-vault-guide',
      title: 'Emergency Vault: Sapa Defense',
      subtitle: 'Building a Bulletproof Safety Net Against Sapa',
      category: 'Savings & Defense',
      level: 'Intermediate',
      readTimeMinutes: 14,
      chapterCount: 4,
      icon: AppIcons.shield,
      author: 'PennyPal Financial Academy',
      summary:
          'A tactical guide to calculating your minimum survival numbers, isolating emergency funds from daily temptations, and staying solvent during price shocks.',
      chapters: [
        BookChapter(
          number: '01',
          title: 'Calculating Your True Survival Baseline',
          readTime: '3 min read',
          summary: 'Finding out how much you actually need to survive for 30 days if all income stops.',
          content: '''
An emergency fund is not an investment fund; it is financial insurance for your mental health and peace of mind.

To build one, first calculate your "Survival Number" (Baseline Monthly Burn Rate). Strip away all entertainment, Netflix, eating out, and new shoes. Add only:
1. Basic nutrition (raw groceries, cooking gas, drinking water).
2. Essential mobility (transport to exams/lectures).
3. Critical connectivity (basic data subscription for school portal and communications).
4. Essential medications and toiletries.

If your survival number is ₦35,000/month, a starter 3-month Emergency Vault equals ₦105,000.
''',
          takeaways: [
            'Calculate your exact bare-bones monthly survival figure down to the last Naira.',
            'Aim for a starter emergency fund of at least 2 months of survival expenses.',
            'Having an emergency buffer protects you from borrowing money at predatory interest rates.',
          ],
        ),
        BookChapter(
          number: '02',
          title: 'Where to Store Your Emergency Funds',
          readTime: '3 min read',
          summary: 'Why your regular daily bank card account is the worst place for emergency savings.',
          content: '''
If your emergency savings are connected to the same debit card you use for cafeteria POS payments or online checkout, that money will vanish.

Human friction is necessary for discipline. Your emergency vault must meet two strict criteria:
1. High Liquidity: Accessible within 24 hours if a real crisis occurs (e.g. sudden illness, family emergency, damaged laptop before exams).
2. Intentional Friction: Not accessible with a single swipe or impulse tap.

Keep your emergency funds in a dedicated PennyPal Vault with strict withdrawal rules so you never accidentally spend it on Saturday night pizza.
''',
          takeaways: [
            'Do not link your emergency funds to your everyday debit card.',
            'Create digital separation between "spending cash" and "safety vault".',
            'Keep emergency money liquid, safe, and capital-protected rather than chasing risky speculative yields.',
          ],
        ),
        BookChapter(
          number: '03',
          title: 'What Counts as a True Emergency?',
          readTime: '4 min read',
          summary: 'The 3-question filter to determine if you should touch your emergency reserve.',
          content: '''
Before you withdraw even ₦1 from your emergency fund, ask yourself these 3 qualifying questions:

1. Is it Unexpected? (A birthday gift or Christmas clothes are NOT emergencies — they happen every year on the same date).
2. Is it Urgent? (Will there be severe academic, legal, or health consequences if not settled in 24-48 hours?)
3. Is it Necessary? (Is this required for survival or vital coursework, or is it a luxury upgrade?)

If the answer to all three is not an undeniable YES, your emergency vault remains strictly locked.
''',
          takeaways: [
            'Annual events and holidays are planned expenses, not emergencies.',
            'Health issues, critical school equipment failure, and sudden price shocks are true emergencies.',
            'Replenish your vault immediately whenever an emergency forces you to make a withdrawal.',
          ],
        ),
        BookChapter(
          number: '04',
          title: 'Rebuilding Your Safety Net After a Crisis',
          readTime: '4 min read',
          summary: 'The step-by-step recovery plan after an unexpected expense drains your reserves.',
          content: '''
Emergencies happen to everyone. When you have to use your emergency fund, congratulations — it did its job! You survived a financial shock without sinking into high-interest debt or panicking.

However, once the storm passes, your top financial priority must be replenishment:
1. Temporarily pause all non-essential discretionary spending for 30-60 days.
2. Direct 50% of any spare allowance, gifts, or side income straight into rebuilding the vault.
3. Review what caused the emergency: was it preventable with maintenance (e.g. servicing your phone battery early)?

Once your vault is full again, you can resume normal savings goals for vacations, gadgets, and personal milestones.
''',
          takeaways: [
            'Do not feel guilty for spending emergency money on genuine emergencies.',
            'Put lifestyle upgrades on temporary hold until your safety buffer is restored.',
            'A fully funded emergency vault gives you unbeatable confidence and calm.',
          ],
        ),
      ],
    ),
    LearningBook(
      id: 'student-wealth-starter-kit',
      title: 'Digital Hustles & First Investments',
      subtitle: 'The Student Wealth Starter Kit',
      category: 'Income & Growth',
      level: 'Advanced',
      readTimeMinutes: 16,
      chapterCount: 4,
      icon: AppIcons.trendingUp,
      author: 'PennyPal Financial Academy',
      summary:
          'A masterclass on monetizing high-value digital skills on campus, understanding compound interest, and avoiding fraudulent get-rich-quick traps.',
      chapters: [
        BookChapter(
          number: '01',
          title: 'High-Income Skills You Can Learn on Campus',
          readTime: '4 min read',
          summary: 'Monetizing digital competencies alongside your university degree.',
          content: '''
Relying solely on a monthly pocket allowance puts a hard ceiling on your financial growth. The fastest way to increase your savings rate is to increase your top-line earnings.

The internet allows any university student with a smartphone or laptop to earn remote income:
- Technical Writing & Content Strategy: Brands pay ₦20k–₦100k per article.
- Graphic Design & UI/UX (Figma, Canva): Social media graphics, flyers, presentation decks for businesses.
- Campus Tutoring: Teaching junior students difficult STEM courses or coding basics.
- Social Media Management: Managing Instagram/TikTok accounts for local retail brands.

Dedicate 1 hour every evening to skill acquisition. Within 3-6 months, a single remote client can double your monthly allowance.
''',
          takeaways: [
            'Pick ONE specific skill (e.g. copywriting, design, or video editing) and master it before diversifying.',
            'Build a public portfolio on Google Drive, GitHub, or Behance to showcase tangible work.',
            'Never let side gigs compromise your core academic grades — time management is your supreme asset.',
          ],
        ),
        BookChapter(
          number: '02',
          title: 'The Unstoppable Magic of Compound Interest',
          readTime: '4 min read',
          summary: 'Why starting to invest ₦5,000 at age 20 destroys ₦50,000 at age 35.',
          content: '''
Albert Einstein famously called compound interest the eighth wonder of the world: "He who understands it, earns it; he who doesn't, pays it."

Time in the market is vastly more powerful than timing the market.

Imagine Student A: Starts investing ₦10,000/month at age 20 for 10 years and stops at 30, letting it compound at 12% annual return until age 60.
Imagine Student B: Waits until age 35 to start, investing ₦30,000/month for 25 consecutive years until age 60.

Despite Student B investing nearly 3x more total capital out of pocket, Student A ends up with more wealth at retirement purely because their money had an extra 15 years to compound upon itself.
''',
          takeaways: [
            'Your greatest financial advantage right now is your age and the decades of compounding ahead.',
            'Start small: even ₦2,000 or ₦5,000 invested consistently into diversified index funds works wonders.',
            'Reinvest all dividends and earnings rather than cashing them out early.',
          ],
        ),
        BookChapter(
          number: '03',
          title: 'Spotting Ponzi Schemes & Fast-Money Traps',
          readTime: '4 min read',
          summary: 'Recognizing fraudulent investment traps before they wipe out your student savings.',
          content: '''
Nigerian campuses are flooded with financial traps: "Guaranteed 40% monthly returns," "Forex doubling robots," or "Crypto peer-to-peer matrix schemes."

Here are the immutable red flags of a scam:
1. "Guaranteed High Returns with Zero Risk": Legitimate investments always carry risk proportional to return. Anyone promising 20%+ monthly guaranteed is running a Ponzi scheme.
2. Mandatory Referral Recruiting: If your profit depends heavily on bringing 3 new people into the program, it is a pyramid scheme.
3. Vague Business Models: If they cannot clearly explain in simple English how money is actually generated, run away.

Protect your hard-earned capital. Real wealth creation is boring, disciplined, and steady.
''',
          takeaways: [
            'If an opportunity sounds too good to be true, it 100% is a scam designed to take your money.',
            'Never invest student tuition fees, rent, or emergency savings into speculative or unverified platforms.',
            'Stick to regulated financial instruments with transparent custody and proven track records.',
          ],
        ),
        BookChapter(
          number: '04',
          title: 'Designing Your 5-Year Financial Freedom Blueprint',
          readTime: '4 min read',
          summary: 'Crafting a clear trajectory from university graduation to early career financial security.',
          content: '''
Graduation is not the start of your financial journey — it is the midpoint. The habits, savings discipline, and credit awareness you build during school determine whether your post-graduation transition is smooth or stressful.

Your 5-Year Blueprint Checklist:
1. Graduate with ZERO consumer or peer debt.
2. Have a 6-month post-NYSC living expense buffer safely locked away.
3. Possess at least one income-generating digital skill outside your academic degree.
4. Maintain a structured budget tracking system with PennyPal so lifestyle inflation never outpaces earnings.

Financial freedom is not about buying fancy luxury items — it is about having options, autonomy, and the liberty to make career decisions based on passion rather than desperation.
''',
          takeaways: [
            'Build your career and financial foundations simultaneously during your university years.',
            'Avoid lifestyle inflation every time your side hustle or salary income increases.',
            'Use PennyPal daily to stay accountable to your long-term goals.',
          ],
        ),
      ],
    ),
  ];

  static LearningBook? getBookById(String id) {
    try {
      return curatedBooks.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
