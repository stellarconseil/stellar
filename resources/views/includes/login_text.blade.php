
<div class="userloginbox">
	<div class="container">		
		<div class="titleTop">
           <h3>{{__('Are You Looking For Job!')}} </h3>
        </div>
		
		
		@if(!Auth::user() && !Auth::guard('company')->user())
		<div class="viewallbtn"><a href="{{route('register')}}"> {{__('Get Started Today')}} </a></div>
		@else
		<div class="viewallbtn"><a href="{{url('my-profile')}}">{{__('Build Your CV')}} </a></div>
		@endif
	</div>
</div>
