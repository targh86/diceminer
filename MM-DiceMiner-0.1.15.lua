					-- ____
				   -- /\' .\            _____      
				  -- /: \___\          / .  /\     
				  -- \' / . /         /____/..\    
	 -- ____          \/ __/ __       \'  '\  /            
	-- |  _ \(_) ___ ___|  \/  ( )_ __ \'__'\/___ 
	-- | | | | |/ __/ _ \ |\/| | | '_ \ / _ \ '__| 
	-- | |_| | | (_|  __/ |  | | | | | |  __/ |   
	-- |____/|_|\___\___|_|  |_|_|_| |_|\___|_|   
	-- 
	--  FOR THE LOVE OF GOD USE THIS AT YOUR OWN RISK
	--  IT HAS NOT BEEN TESTED ANYWHERE NEAR ENOUGH TO
	--  CLASSIFY AS "STABLE" OR "RELIABLE".  THIS IS
	--	ALPHA-PRODUCTION LEVEL.  STILL IN TESTING.
	--
	--	ALTHOUGH RELEASED PUBLICLY, THIS IS NOT A PUBLIC
	--	RELEASE AND SHOULD NOT BE TREATED AS "WORKING".
	--	IT'S IN HEAVY DEVELOPMENT SO KEEP AN EYE ON THE GIT
	--	
	--	 Git URL:  https://github.com/targh86/diceminer
	--
	--
	--  USAGE: THE STUFF THAT YOU NEED TO SET IS COMMENTED
	--		   CLEARLY WITHIN THE SCRIPT.
	--
	--	NOTE: SOME OF THE COMMENTS ARE LONG AND MAY NOT DISPLAY
	--		  WELL IN DICEBOT/MDB. OPEN THE SCRIPT IN AN APP LIKE
	--		  NOTEPAD++ TO VIEW AND MAKE CHANGES BEFORE IMPORTING
	--		  INTO YOUR DICE APP.
	--
	--	REQUIREMENTS:
	--			- Dicebot 3.x	[Stable Thoroughly Tested]
	--			- MyDiceBot		[Stable Not Thoroughly Tested]
	--
	--	
	--			 RELEASE VERSION 0.1.15
	--
    ------------------------------------------------------
    ---- ---- ---- SET YOUR PARAMETERS HERE ---- ---- ----
    ------------------------------------------------------
function loadUserVariables()
	-- USER PARAMATERS ARE ALL SET HERE AND NOWHERE ELSE --
	
    basechance       = 58			-- what bet chance % you want to use as the base %
    winmultiplier    = 0.95			-- how much to multiply bets by when you win a roll.  [Default 0.95]  HIGHLY RECOMMEND a value < 1
    lossmultiplier   = 3.7255		-- how much to multiply bets by when you lose a roll.  [Default 2.7255]
	chancemode		 = 2			-- chance mode (1 uses a multiplier, 2 uses set chance amounts).
	chancemultiplier = 1.275		-- how much to multiply the chance by (increase) when you lose a roll.  [Default `1.25]
	chancemax		 = 90			-- maximum chance level (%) - stops script from making no profit from spins. [Default 90]
	
    bethigh          = true			-- bet high end of scale.
    betdiv           = 10			-- pushes back decimal place of bet (eg 1000 will make a bet of 1 become 0.0001) [Default 1000]
									-- Suggested Options: 1, 10, 100, 1000, 10000, 100000)
									
	minbet			 = 0.00000010

    spinlimit = 45					-- number of sequential spins before the script forces an unconditional reset. [Default 50]

    plummetthresh  = -3				-- number of losses before script declares a plummet. [Default -3]  (MUST be negative and < -1 )

    inrecmax        = 3				-- number of recovery spins to do after a plummet.  (Don't get carried away here, these spins are exempt from
									-- the rules of the script.  They are hard, fast spins to try and claw back - but with no safety.)  [Default 3]

    inrecmultiplier = 1.2			-- recovery mode multiplier

    minbtcbet = 0.00000005			-- absolute minimum bet for BTC bets - this stops the script from bugging out at 0.00000001btc
									-- minimum value is 0.00000003  [Default 0.00000004]   You may need to increase this if you have
									-- your chancemax set too high.  Experiment and test.


	-- CRYPTO WALLET ADDRESSES		-- where to withdrawl to (NOT FULLY IMPLEMENTED YET)
	
	extwalletbtc = "bc1qe7lfanpd53gdkkxkuv5rfzdawl75uj7cthyr0f"   		-- BTC Wallet Address
	extwallettrx = "THfK7AXC6qmmY76kExvPjwe9adjs394STS"					-- TRX Wallet Address
	
end
	
	
	
	--------------------------------------------------------------------
	---- ---- YOU DO NOT NEED TO EDIT ANYTHING BELOW THIS LINE ---- ----
	--------------------------------------------------------------------
	
	
	
	   --! -- BEGIN LOADING SCRIPT CORE FUNCTIONS -- !--
	
	
	
    ------------------------------------------------------
    --------------- UPDATE BASE BET MODE -----------------
    ------------------------------------------------------
        function updatebasebet(showsummary)
            basebet       = (((balance/2) * (1/(basechance)))/betdiv)		-- sets base bet using equation.
			if basebet < minbet then basebet = minbet end					-- if the resulting basebet is smaller than the user-defined minbet then default it to minbet value

            sessionprofit = (balance - startbalance)						-- calculate the profit made this session.
            profitmax  = ((basebet * 3.7255^8)/125)								-- set the max profit threshold in a bet before resetting.

			lossmaxa = (((0-((balance/2)))/betdiv)/2)							-- loss max equation 1
			lossmaxb = ((0-basebet*10)/2)										-- loss max equation 2
			lossmaxc = (((0-(basebet * 3.7255^8))/betdiv)/2)					-- loss max equation 3
			lossmax = lossmaxa												-- sets lossmax to eqation 1 as default.
			if lossmaxb < lossmax then lossmax = lossmaxb end				-- checks if equation 2 is lower val (if it is, override)
			if lossmaxc < lossmax then lossmax = lossmaxc end				-- checks if equation 3 is lower val (if it is, override)
																			-- this ensures we allow for the largest desireable loss while betting.  Allows for more headroom.

			betceiling = ((basebet * (3.72558^8))/100)						-- set the bet ceiling (maximum bet)

			betfloor   = (((basebet / 3.72558)^8)*100)						-- set the bet floor (minimum bet amount)
			
			if showsummary then
			print("[INFO] Updating base bet and bet parameters.")					-- don't forget nextbet isn't set here!
			print("  - Base: "..printval(basebet))									-- set it in the place you called this function from!
			print("  - Max Profit (in a spin): "..printval(profitmax))			
			print("  - Max Loss (in a spin): "..printval(lossmax))
			print("  - Bet Ceiling: "..printval(betceiling))
			print("  - Bet Floor: "..printval(betfloor))
			print("  - This Session Profit: "..printval(sessionprofit))
			printwhitespace(1)
			end
			
        end
    ------------------------------------------------------
    ---------- DISPLAY BET INFORMATION TO CONSOLE --------
    ------------------------------------------------------
    function displaybetinfo()
		printwhitespace(1)
		if (win == false) then        
			print("========= L O S S =========")
		elseif (win == true) then
			print("========== W I N ==========")
		end
		printwhitespace(1)

		print("LAST BET DETAILS")
		print("Profit: "..printval(currentprofit).."  |  Streak: "..currentstreak)
        print("Ceiling: "..printval(betceiling).."  |  Floor: "..printval(betfloor).." | Profit Thresh: "..printval(profitmax).."  |  Loss Thresh: "..printval(lossmax))
        print("Chance: "..chance.."  |  Base Chance: "..basechance.."  |  Chance Mode: "..tostring(chancemode))
        print("LastGood: "..printval(lastgoodbet).."  |  Session Profit: "..printval(sessionprofit))

		checkspincount()
		print("======================")
		printwhitespace(1)
    end
    ------------------------------------------------------
    ----------------- DISPLAY NEXTBET INFO ---------------
    ------------------------------------------------------
    function nextbetsummary()
        -- Output what the next bet is going to be
        print("NEXT BET: "..printval(nextbet).." at "..chance.."% chance")
		printwhitespace(5)
		print("[INFO] STARTING NEXT BET...")
    end
	
	
    ------------------------------------------------------
    -------------------- SET BET CHANCE ------------------
    ------------------------------------------------------
    function setbetchance()

		------------- CHANCE MODE 1 - MULTIPLIER -------------
	if (chancemode == 1) then							-- chancemode 1 uses a set multiplier every bet (until ceiling)
	    if (win == true) then
			print("   (Win) Chance Set: "..chance.."%")
			chance = basechance
		else
			chance = chance*chancemultiplier
			print("   (Loss) Chance Set: "..chance.."%")
		end
		
		if chance > chancemax then			-- checks that the chance % isn't over the user's defined maximum.
			chance = chancemax
        end
			
	print("Chance Set: "..chance)
	end

		------------- CHANCE MODE 2 - BETMATRIX -------------
		-- chancemode 2 uses predetermined bet multipliers and chance values.
	if (chancemode == 2) then

		if (win == true) then
			chance = basechance
			if (currentstreak == 1) then
				nextbet = basebet
				else
				nextbet = (previousbet * winmultiplier)
			end

		print("   (Win) Chance Matrix: "..currentstreak.."  |  Chance: "..chance.."  |  Next Bet: "..nextbet)
		
		else
			print("   (Loss) Streak: "..currentstreak.."  |  Losing Bet: "..losingbet)
			
			if (currentstreak == -1) then
					chance = chance1
					losingbet = previousbet
					nextbet = losingbet*m1
			end

			if (currentstreak == -2) then
					chance = chance2
					nextbet = losingbet*m2
			end
			
			if (currentstreak == -3) then
					chance = chance3
					nextbet = losingbet*m3
			end
			
			if (currentstreak == -4) then
					chance = chance4
					nextbet = losingbet*m4
			end

			if (currentstreak == -5) then
					chance = chance5
					nextbet = losingbet*m5
			end
			

			if (currentstreak == -6) then
					chance = chance6
					nextbet = losingbet*m6
			end

			
			if (currentstreak == -7) then
					doscriptreset(1)
					chance = chance7
					nextbet = losingbet*m7
			end		

			if (currentstreak <= -8) then
					chance = chance1
					nextbet = losingbet*m1
			end		

			print("   (Loss) Next Bet: "..nextbet)
			
		end
		end
		end
		
    ------------------------------------------------------
    --------------- DETERMINE WIN / LOSS -----------------
    ------------------------------------------------------
    function checkbetoutcome()
	highlowcount()				-- High/Low Bet Tally Counter
    if (win == false) then        
			print("   (Loss) - Preparing Next Bet...")
			setbetchance()

				if (chancemode == 1) then							-- Chance Mode 1 takes the previous bet and multiplies it by the set loss multiplier.
					nextbet = (previousbet*lossmultiplier)
					print("   (Loss) Adjust Bet (Multiplier) "..lossmultiplier.."x  -  Prev: "..printval(previousbet).." >>  Next: "..printval(nextbet))
				end

        elseif (win == true) then
			sethighlow()											-- Set's the bethigh for the next bet.
            if (currentstreak == 1) and lastgoodbet > previousbet then
					nextbet = lastgoodbet
					updatebasebet(true)
					print("    (Win)  LGB PICKUP (1st Win) - Resuming Last Good Bet: "..nextbet)
					setbetchance()
            else
				setbetchance()
				lastgoodbet = previousbet
				nextbet = (previousbet*winmultiplier)
				print("    (Win)  Bet Multiplier: "..winmultiplier.."x")
			end

			if (chance == !basechance) then
				chance = basechance						-- immediately revert to base chance.
				print("    (Win)  Reset Chance: "..chance)
			end
        end
    end
	
	
    ------------------------------------------------------
    ---------- BET LIMITATIONS / RESTRICTIONS ------------
    ------------------------------------------------------
    function checklimits()
        
        if (inrecover == false) then
            
            -- Check if the bet ceiling has been hit --
            if nextbet > betceiling then
                print("    BET CEILING HIT - CAPPING BET")
				nextbet = betceiling
                updatebasebet()
            end

            -- Check if the bet floor has been hit
            if nextbet < betfloor then
                print("    BET FLOOR HIT - RESETTING")
				doscriptreset(0,false)
            end
            
            -- Check Profit Threshold
            if (currentprofit > profitmax) then
                print("    PROFIT MAX THRESHOLD HIT - RESETTING")
   				doscriptreset(0,false)
            end

            -- Check Loss Threshold
            if (currentprofit < lossmax) then
                print("    PROFIT LOSS THRESHOLD HIT - RESETTING")
				doscriptreset(0,false)
            end

            -- Check Streak
            if (currentstreak == 10) then
                print('    STREAK HIT - CONSECUTIVE WINS - RESETTING LGB')
				doscriptreset(2,true)
            end
            
        else
                print("[NOTICE] Skipping Threshold Checks During Recovery")
        end
    end
    ------------------------------------------------------
    ------------------- SPIN COUNTER ---------------------
    ------------------------------------------------------
	function checkspincount()
            if (spincount < spinlimit) then
                spincount = spincount + 1
                print("SPIN "..spincount.." / "..spinlimit)
            else    
                print("[INFO] Spin Limit Reached. Script Resetting.")
                doscriptreset(1,true)
            end
	end
    ------------------------------------------------------
    ------------------ RECOVERY MODE ---------------------
    ------------------------------------------------------
    function recoverycheck()
        if (win==false) and (inrecover == true) then
			print("[INFO] Recovery Interrupted by Loss.")
			inrecover = false
			inrecspin = 0
			inplummet = false
        end

    -- RECOVERY MODE TRIGGER CHECK
	-- Check if we've just hit a win while we were in a plummet.
	
        if (inplummet == true) and (currentstreak == 1) then
            inrecover = true    
            inrecspin = 0
            inplummet = false
			print("[INFO] PLUMMET ENDED!")

         -- See if the plummet bank amt is more than next bet. If so, override it
            if ((inplumbank * inrecmultiplier) > (nextbet * inrecmultiplier)) then
                nextbet = (inplumbank * inrecmultiplier)
				print("  Overriding next bet with pre-plummet bet value")
			else
				nextbet = (nextbet * inrecmultiplier)
            end

        end

	 -- RECOVERY MODE HIGH STAKES SPINS

     if (inrecover == true) then
            inrecspin = inrecspin + 1					-- Because we're dealing with the NEXT spin, we're +1 here.
         
            if (inrecspin <= (inrecmax+1)) then
				printwhitespace(3)
                print("  !!  RECOVERY MODE HIGH STAKES  !! ")
                print(" ")
                print("      SPIN: "..(inrecspin-1).." of "..inrecmax)
            else
                print("      SPIN: "..(inrecspin-1).." of "..inrecmax)
                print("      HIGH STAKES SPINS FINISHED")
				printwhitespace(1)

				-- if the bet before plummet was bigger than the base, we'll use it. Otherwise we'll use the base.
				if (inplumbank > basebet) then
					nextbet = (inplumbank)
					print("      RECOVERY FINISHED: Restoring bet to pre-plummet value of "..nextbet)
				else
					nextbet = (basebet)
					print("    REC FINISHED: Restoring bet to base value of "..nextbet)
				end
                inrecover = false
            end
        end
    end
    ------------------------------------------------------
    ------------------- PLUMMET MODE ---------------------
    ------------------------------------------------------
    function plummetcheck()
        -- Check Plummet Status
        if (currentstreak == (plummetthresh+1)) then
            print(" ")
            print("     [ALERT] START OF PLUMMET")
            inplummet = true
        else
            inplummet = false
        end

        -- Check if start of plummet
        if (currentstreak == (plummetthresh+1)) then
            print("     |---> Beginning of plummet - Setting Bank")
            inplumbank = previousbet
            print("     |---> Setting Recovery Value: "..inplumbank)
        end


        -- What to do if plummeting
        if (inplummet == true) then
            print("     |---> Plummet Overriding Multiplier: "..plummultiplier.." Applying to bet...")
            nextbet = (previousbet*plummultiplier)
            print("     |---> Next bet now set to "..nextbet)
            print(" ")
        end
    end        
    ------------------------------------------------------
    -----------------   RESET SCRIPT   -------------------
    ------------------------------------------------------
	function doscriptreset(resettype,newseed)
	-- Performs Full Script Reset.
	-- Usage
	-- call doscriptreset(options) from within the script
	--
	-- Options: 
	-- Reset Type: 0 = Standard (Resets Rolling Variables)	1 = Full (Performs a reset and performs script init again)
	--             2 = LGB (Resets rolling variables according to Last Good Bet)
	--
	-- New Seed:   true = Resets Seed with Server
	--
	--
		print("--------------------------------------")
		print("[INFO] Resetting")
			if !resettype then 
				print("[INFO] Reset type not defined. Setting to default (0 - Rolling)")
				resettype = 0
			end
			
			if (doresetlgb == true) then			-- Checks LGB flag.
				resettype = 2
			end

            updatebasebet()					-- Update the basebet and other params.

			print("   ")
			print("   ")
				
			if (resettype == 0) then			-- Rolling Variables
					print("  - Rolling Reset...")
					nextbet = basebet
					print("  - Next Bet: "..nextbet)
					firstbet = basebet
					print("  - Initial Bet: "..firstbet)
					chance = basechance
					print("  - Chance Reset: "..chance)
					lastgoodbet = basebet
					print("  - Restting Last Good Bet: "..lastgoodbet)
			end
				
			if (resettype == 1) then			-- Reset All (Full Init)
					print("  - Full Init Reset...")
					nextbet = basebet
					print("  - Next Bet: "..nextbet)
					firstbet = basebet
					print("  - Initial Bet: "..firstbet)
					chance = basechance
					print("  - Chance Reset: "..chance)
					lastgoodbet = basebet
					print("  - Restting Last Good Bet: "..lastgoodbet)
					resetseed()
					print("  !! RE-INITIALIZE SCRIPT... LOADING... ")
					initscript()
					print("  !! RE-INITIALIZE SCRIPT COMPLETED.")
			end		
		
			if (resettype == 2) then			-- Rolling Variables LGB Mode
					print("     LGB Reset - Last Good Bet is now the BASE and FIRST bet.")
					print("     Last Good Bet is: "..lastgoodbet)
					nextbet = lastgoodbet
					print("     Next Bet: "..nextbet)
					firstbet = lastgoodbet
					print("     Initial Bet: "..firstbet)
					chance = basechance
					print("     Chance Reset: "..chance)
					basebet = lastgoodbet
					doresetlgb = false
			end

			spincount = 0						-- Set spin count back to 0
			print("     Spin Count Reset: "..spincount)

			doreset     = false 				-- Turn off flag
			print("     Reset flag turned off")
			
			if newseed then						-- Resets seed if requested.
				if (newseed == true) then
					resetseed()
				end
			end
			
		print("[INFO] Reset Complete")
		printwhitespace(2)
	end
	------------------------------------------------------
    ------------ CHECK BTC GLOBAL PARAMETERS -------------
    ------------------------------------------------------
        function checkbtc()
           if (currency == "btc") and (nextbet < minbtcbet) then
                print("Notice: Minimum BTC Bet reached.  Setting to "..minbtcbet)
                nextbet = minbtcbet
           end
        end
    ------------------------------------------------------
    ------------- CHECK FOR BLOWN THE BANK ---------------
    ------------------------------------------------------
    function checkblowbank()
        if (inrecover == false) then
            if (nextbet > ((((balance)*0.33)))) then
                print("[INFO] BLOWN THE BANK   (Too High % Bet)")
                nextbet = (((balance)*0.33))
				print("  Next bet now set to 33%: "..printval(nextbet))
				printwhitespace(2)
            end
		end
    end
    ------------------------------------------------------
    ------------ ROUND FUNCTION FOR CONSOLE --------------
    ------------------------------------------------------

    function printval(valnum)
        return(string.format("%.12f",valnum))
    end
    ------------------------------------------------------
    ------------ PRINT WHITE SPACE IN CONSOLE ------------
    ------------------------------------------------------
    function printwhitespace(numlines)	
		for whitespace = 1,numlines,1 	--Generate whitespace
		do
			print(" ")
		end
	end
	
    ------------------------------------------------------
    --------------- DETERMINE HIGH/LOW BET ---------------
    ------------------------------------------------------	
	function sethighlow()

        if highCount > lowCount then
			bethigh=true
        else
			bethigh=false
        end

        if (highCount-lowCount) > 15 then
			bethigh=false
        end

        if (lowCount-highCount)> 15 then
			bethigh=true
        end
	print("Setting bethigh: "..tostring(bethigh))
	
	end
	
    ------------------------------------------------------
    ------------- UPDATE THE HIGH/LOW COUNT --------------
    ------------------------------------------------------	

	function highlowcount()
	
		if (lastBet.roll < chance) then
			lowCount += 1										-- add to lowCount tally
		end

		if (lastBet.roll > (99.99 - chance)) then
			highCount += 1										-- add to high tally
		end 
	end


    ------------------------------------------------------
    --------------- RANDOM CHANCE MODE ROLL --------------
    ------------------------------------------------------	
	function chancemoderand()
	-- determines whether we're betting high or low (heads/tails)
	print("[INFO] Chance Mode Roll:  Determining chance type for this session.")
	if (math.random(0,100) > 49.99) then chancerandsethigh = true end
	chancerandseed = ((((math.random(0,(100*basechance))) + (math.random(0,(100*basechance)))) / 2) / basechance)
	print("[INFO] Chance Mode Roll:  Randomly generating seed: "..chancerandseed.."  |  Bet High: "..tostring(chancerandsethigh))
	if (chancerandseed > 49.99) and (chancerandsethigh == true) then chancemode = 2 else chancemode =1 end
	if (chancemode == 1) then print("[INFO] Chance Mode Roll:  Selected Chance Mode: Multiplier") else print("[INFO] Chance Mode Roll:  Selected Chance Mode: Matrix") end
	end
	
    ------------------------------------------------------
    ----------- SCRIPT INITIALIZE AND STARTUP ------------
    ------------------------------------------------------
	function initscript()
		resetstats()
		loadUserVariables()				-- loads the manually set parameters at start of script.
		printwhitespace(75)
		print("---------------------------------")
		print("DiceMiner Script LUA for DiceBot")
		print("Script Starting...")
		print(" ")
		startbalance   = balance
		print("Set Starting Balance: "..startbalance)

		print("Chance Mode: "..tostring(chancemode).."      (1 = Multiplier, 2 = Matrix)")
		print("Set Base Chance: "..basechance)
		print("Setting up chance matrix...")
	
		chance1 = 82.541  -->1.2X payout
		chance2 = 76.221  -->1.3X payout
		chance3 = 70.783  -->1.4X Payout
		chance4 = 66.051  -->1.5X Payout
		chance5 = 70.783  -->2.1X Payout
		chance6 = 76.221  -->3.2X Payout
		chance7 = 82.541  -->3.95X Payout

		m1 = 6.504            
		m2 = 4.501
		m3 = 3.752
		m4 = 3.1
		m5 = 3.752
		m6 = 4.501
		m7 = 6.504
		
		losecount = 0
		
		print("Set Win x: "..winmultiplier)
		print("Set Loss x: "..lossmultiplier)

		if !currency then			  -- fix for MyDiceBot
			currency = "NA"
		end
	
		sessionprofit = 0			  -- new session, nil profit.
	
		print("External Wallets:")
		print(" (BTC): "..extwalletbtc)
		print(" (TRX): "..extwallettrx)
		print(" ")

		if not !currency then													-- Display in use currency.
			print("[INFO] Crypto Currency In Use: "..currency)
		end

		print("[INFO] Setting Startup Parameters")
		firstbet    = 0.00000001									-- Sets the value for first bet of the session.
		nextbet     = 0.00000001									-- Prepares next (first) bets value.
		lastgoodbet = 0.00000001									-- Loads base bet as last good bet until one is set.

		chance      = basechance						-- Sets the base chance as the next chance
		highCount	= 0									-- Tally of High Bets
		lowCount    = 0									-- Tally of Low Bets

		enablezz    = false								-- Allow       
		enablesrc   = false     						-- Use Advanced options from Dicebot
		doreset     = false

		chancemoderand()
		updatebasebet()									-- Update basebet and other rolling parameters.
														--------------------------------------------------
		nextbet = basebet								-- Re-set bet parameter after
		firstbet = basebet								-- update function (required for initial startup)
		lastgoodbet = basebet							--------------------------------------------------
	
		print("Next: "..printval(nextbet).." | LGB: "..printval(lastgoodbet).." | Chance:"..chance)


		spincount = 0
		inplummet      = false
		inplumbank     = basebet
		plummultiplier = (winmultiplier/1.33)

		inrecover       = false
		inrecspin       = 0
		
		print("[INFO] Initialization Completed...")
		print("  SUMMARY:")
		print("  Base Bet: "..printval(basebet).."  |  Currency: "..currency)
		print("  External Wallet: "..extwalletbtc)
		print("  Win Multiplier: "..winmultiplier.."  |  Loss Multiplier: "..lossmultiplier)
		printwhitespace(5)
		print("BETS STARTING IN...")
		print("5")
		sleep(1000)
		print("4")
		sleep(1000)
		print("3")
		sleep(1000)
		print("2")
		sleep(1000)
		print("1")
		sleep(1000)
		print("0")
	end
    ------------------------------------------------------
    ------------------------------------------------------
	
	
			--! -- END SCRIPT CORE FUNCTIONS -- !--
	
	
    ------------------------------------------------------


    ------------------------------------------------------
				--! -- EXECUTE FUNCTIONS -- !--
    ------------------------------------------------------
	-- Initialize Script.
		initscript()				-- Runs all of the init commands that set / update base functions of the script.
									-- Also loads all of the user-defined settings at the beginning of this script.
	-- dobet Loop
		function dobet()
			displaybetinfo()		-- Displays previous bet's detailed information
			checkbetoutcome()		-- Checks the previous bet's outcome, sets basic parameters for next bet and displays details in console
			
			if chancemode == 1 then		-- Only do plummet and recovery checks if using chancemode 1 (Multiplier)
				recoverycheck()			-- Check to see if the next spin is in recovery mode (return out of plummet).
				plummetcheck()			-- Check to see if the next spin is in a plummet.
				checkblowbank()			-- Check that the next spin isn't going to blow the bank (ie. spend more than x% of your balance).
			end

			checklimits()			-- Check the next spin against the basic bet limits and rules established.
			checkbtc()				-- Check if the balance meets minimum bet requirements for BTC (if using it).
			nextbetsummary()		-- Display a summary of the next bet before spinning again.
		end